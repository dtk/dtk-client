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
        module_refs.each do |module_ref|
          if module_exists?(module_ref, { :type => :component_module })
            OsUtil.print("Using module '#{module_ref.namespace}:#{module_ref.module_name}'")
            # If component module is imported, still check to see if it's dependencies are imported
            find_and_install_component_module_dependency(module_ref, opts)
          else
            install_module(module_ref, opts)
          end
        end
      end

      private

      def self.install_module(component_module, opts = {})
        namespace   = component_module.namespace
        module_name = component_module.module_name
        version     = component_module.version

        import_msg = "Importing module '#{namespace}:#{module_name}"
        import_msg += "(#{version})" if version && !version.eql?('master')
        import_msg += "' ... "

        # Using print to avoid adding cr at the end.
        print "\n" if opts[:add_newline]
        print import_msg

        post_body = {
          :module_name => module_name,
          :namespace   => namespace,
          :rsa_pub_key => SSHUtil.rsa_pub_key_content(),
          :version?    => version
        }

        unless opts[:skip_dependencies]
          find_and_install_component_module_dependency(component_module, opts.merge(:add_newline => true))
        end

        response = rest_post "#{BaseRoute}/install_component_module", PostBody.new(post_body)

        clone_args = {
          :module_type => :component_module,
          :repo_url    => response.required(:repo_url),
          :branch      => response.required(:workspace_branch),
          :module_name => response.required(:full_module_name)
          # :remove_existing  => remove_existing
        }
        ClientModuleDir::GitRepo.clone_module_repo(clone_args)

        OsUtil.print_info('Done.')

        response
      end

      def self.get_module_dependencies(component_module)
        query_string_hash = QueryStringHash.new(
          :module_name => component_module.module_name,
          :namespace   => component_module.namespace,
          :rsa_pub_key => SSHUtil.rsa_pub_key_content,
          :version?    => component_module.version
        )
        rest_get "#{BaseRoute}/module_dependencies", query_string_hash
      end

      def self.find_and_install_component_module_dependency(component_module, opts = {})
        dependencies = get_module_dependencies(component_module)

        are_there_warnings = RemoteDependency.check_permission_warnings(dependencies)
        are_there_warnings ||= RemoteDependency.print_dependency_warnings(dependencies, nil, :ignore_permission_warnings => true)

        if are_there_warnings
          return false unless Console.prompt_yes_no("Do you still want to proceed with import?", :add_options => true)
        end

        if missing_modules = dependencies.data(:missing_module_components)
          unless missing_modules.empty?
            dep_module_refs = (missing_modules || []).map do |ref_hash|
              ModuleRef.new(:namespace => ref_hash['namespace'], :module_name => ref_hash['name'], :version => ref_hash['version']) 
            end
            install_dependent_modules(dep_module_refs, opts.merge(:skip_dependencies => true))
          end
        end
      end

    end
  end
end


