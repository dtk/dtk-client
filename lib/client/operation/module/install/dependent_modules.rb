#
# Copyright (C) 2010-2016 dtk contributors
#
# This file is part of the dtk project.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
module DTK::Client
  class Operation::Module::Install
    class DependentModules < Operation::Module
      require_relative('dependent_modules/mixin')
      # mixin must go before print_helper and install_module
      require_relative('dependent_modules/prompt_helper')
      require_relative('dependent_modules/print_helper')
      require_relative('dependent_modules/install_component_module')

      BaseRoute  = "modules"
      # opts can have keys:
      #   :base_component_module_ref
      #   :skip_prompt
      
      def initialize(component_module_refs, opts = {})
        # TODO: in an later release will changes this so iterating over module_refs, which could have component and service info, 
        # not just component modules
        @component_module_refs     = component_module_refs 
        @prompt_helper             = PromptHelper.new(:update_all  => opts[:skip_prompt])
        @print_helper              = PrintHelper.new
        @loaded_module_refs        = []
      end
      private :initialize

      def self.install(module_refs, opts = {})
        new(module_refs, opts).install
      end

      def install
        # Doing breadth first installation of nested dependencies
        @component_module_refs.each do |module_ref|
          unless loaded_already?(module_ref)
            # Base module is installed when base is installed
            InstallComponentModule.install?(module_ref, @prompt_helper, @print_helper) unless module_ref.is_base_module?
            @loaded_module_refs << module_ref
            # TODO: install recursive dependencies
          end
        end
      end

      private

      def loaded_already?(module_ref)
        module_name = module_ref.module_name
        if match = @loaded_module_refs.find { |loded_module_ref| loded_module_ref.module_name == module_name }
          # see if the match is same version and namespace
          unless loded_module_ref.namespace == module_ref.namespace and loded_module_ref.version == module_ref.version
            # TODO: DTK-2766: handle version conflicts, initially by ignoring, but printing message about conflct and what is chosen
          end
          true
        end
      end


      # TODO: below were temporally removed and used for next level of nesting; they wll be put back in
      def get_module_dependencies(component_module)
        query_string_hash = QueryStringHash.new(
          :module_name => component_module.module_name,
          :namespace   => component_module.namespace,
          :rsa_pub_key => SSHUtil.rsa_pub_key_content,
          :version?    => component_module.version
        )
        rest_get "#{BaseRoute}/module_dependencies", query_string_hash
      end

      def find_and_install_component_module_dependency(component_module, opts = {})
        begin
          dependencies = get_module_dependencies(component_module)
        rescue Error::ServerNotOkResponse => e
          # temp fix for issue when dependent module is imported from puppet forge
          if errors = e.response && e.response['errors']
            dependencies = nil if errors.first.include?('not found')
          else
            raise e
          end
        end

        return unless dependencies

        are_there_warnings = RemoteDependency.check_permission_warnings(dependencies)
        are_there_warnings ||= RemoteDependency.print_dependency_warnings(dependencies, nil, :ignore_permission_warnings => true)

        if are_there_warnings
          return false unless Console.prompt_yes_no("Do you still want to proceed with import?", :add_options => true)
        end

        if (missing_modules = dependencies.data(:missing_module_components)) && !missing_modules.empty?
          dep_module_refs = (missing_modules || []).map do |ref_hash|
            ModuleRef.new(:namespace => ref_hash['namespace'], :module_name => ref_hash['name'], :version => ref_hash['version']) 
          end
          install_module_refs(dep_module_refs, opts.merge(:skip_dependencies => true))
        end

        if (required_modules = dependencies.data(:required_modules)) && !required_modules.empty?
          dep_module_refs = (required_modules || []).map do |ref_hash|
            required_modules.uniq!
            ModuleRef.new(:namespace => ref_hash['namespace'], :module_name => ref_hash['name'], :version => ref_hash['version']) 
          end
          pull_module_refs?(dep_module_refs, opts.merge(:skip_dependencies => true))
        end
      end

      def pull_module_refs?(module_refs, opts = {})
        module_refs.each do |module_ref|
          print_using_message(opts)
          pull_module?(opts)
        end
      end

    end
  end
end


