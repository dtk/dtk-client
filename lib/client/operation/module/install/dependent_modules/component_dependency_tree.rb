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
module DTK::Client; class Operation::Module::Install
  class DependentModules
    class ComponentDependencyTree <  Operation::Module
      include DependentModules::Mixin

      BaseRoute  = "modules"

      # opts can have keys:
      #   :children
      def initialize(module_ref, opts = {})
        @module_ref        = module_ref
        @children          = (opts[:children_module_refs] || []).map { |module_ref| self.class.new(module_ref) }
        @first_level_added = !opts[:children].nil?
      end
      private :initialize

      def self.create(module_ref, children_module_refs)
        new(module_ref, :children_module_refs => children_module_refs).recursively_add_children!
      end

      def recursively_add_children!
        add_children_first_level! unless @first_level_added
        @first_level_added = true
        @children.each { |child| child.recursively_add_children! }
        self
      end

      private

      def add_children_first_level!
        # TODO: stub
        pp [:get_component_module_dependencies, get_component_module_dependencies]
      end
      
      def get_component_module_dependencies
        # TODO: meantain a cache so dont have to query dependencies twice
        hash = {
          :module_name => module_name,
          :namespace   => namespace,
          :rsa_pub_key => SSHUtil.rsa_pub_key_content,
          :version?    => version
        }
        rest_get "#{BaseRoute}/module_dependencies", QueryStringHash.new(hash)
      end
    end
  end
end; end
=begin 
      # TODO: old that wil be used to some exten\t
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
=end


