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
    class ExternalModule < self
      BaseRoute = "modules"

      def self.install_dependent_modules(module_refs, opts = {})
        return if module_refs.empty?

        # DTK-2554: Aldin: Remove all 'Puts' and use on of the OSUtil.print_info methods
        puts 'Auto-importing missing dependencies'

        module_refs.each do |module_ref|
          next if module_exists?(module_ref, "component_module")
          install_module(module_ref, opts)
        end
      end

      # DTK-2554: Aldin: want to try to make whatever possible private
      private

      def self.install_module(component_module, opts = {})
        namespace   = component_module.namespace
        module_name = component_module.module_name
        version     = component_module.version

        import_msg = "Importing module '#{namespace}:#{module_name}"
        import_msg += "(#{version})" if version
        import_msg += "' ... "
        # DTK-2554: Aldin: use OSUtil.print_info methods
        print import_msg

        post_body = {
          :module_name => module_name,
          :namespace   => namespace,
          :rsa_pub_key => SSHUtil.rsa_pub_key_content()
        }

        if version = component_module.version
          post_body.merge!(:version => version)
        end

        unless opts[:skip_dependencies]
          dep_response = get_module_dependencies(component_module)

          are_there_warnings = RemoteDependency.check_permission_warnings(dep_response)
          are_there_warnings ||= RemoteDependency.print_dependency_warnings(dep_response, nil, :ignore_permission_warnings => true)

          # prompt to see if user is ready to continue with warnings/errors
          if are_there_warnings
            return false unless Console.prompt_yes_no("Do you still want to proceed with import?", :add_options => true)
          end

          if missing_modules = dep_response.data(:missing_module_components)
            unless missing_modules.empty?
              dep_module_refs = (missing_modules || []).map { |module_ref_hash| ModuleRef.new(module_ref_hash) }
              install_modules(dep_module_refs, :skip_dependencies => true)
            end
          end
        end

        response = rest_post "#{BaseRoute}/install_component_module", PostBody.new(post_body)
        # DTK-2554: Aldin: Remove all 'Puts' and use on of the OSUtil.print_info method
        puts 'Done.'

        response
      end

      def self.get_module_dependencies(component_module)
        post_body = {
          :module_name => component_module.module_name,
          :namespace   => component_module.namespace,
          :rsa_pub_key => SSHUtil.rsa_pub_key_content()
        }
        if version = component_module.version
          post_body.merge!(:version => version)
        end

        rest_post "#{BaseRoute}/create_component_module", PostBody.new(post_body)
      end

    end
  end
end

