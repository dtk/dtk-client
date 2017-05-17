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
      require_relative('dependent_modules/prompt_helper')
      require_relative('dependent_modules/component_dependency_tree')
      require_relative('dependent_modules/component_module')
      require_relative('dependent_modules/local_dependencies')
      require_relative('dependent_modules/remote_dependencies')

      BaseRoute  = "modules"
      # opts can have keys:
      #   :update_deps
      #   :no_update_deps
      def initialize(base_module_ref, component_module_refs, opts = {})
        # TODO: DTK-2766: in an later release will changes this so iterating over module_refs, which could have component and service info, 
        # not just component modules
        @base_module_ref       = base_module_ref
        @component_module_refs = component_module_refs 
        @print_helper          = PrintHelper.new(:module_ref => @base_module_ref, :source => :remote)
        @prompt_helper         = PromptHelper.new(:update_all => opts[:update_deps], :update_none => opts[:update_none]|| opts[:no_update_deps])
        @opts                  = opts
      end
      private :initialize

      # same args as initialize
      def self.install(*args)
        new(*args).install
      end

      def self.install_with_local(*args)
        new(*args).install_with_local
      end

      def self.resolved
        @resolved ||= []
      end

      def self.add_to_resolved(module_name)
        resolved << module_name
      end

      def install
        @print_helper.print_getting_dependencies
        unified_module_refs = get_unified_dependent_module_refs
        unless unified_module_refs.empty?
          case @opts[:mode]
          when 'pull'
            @print_helper.print_pulling_dependencies
          else
            @print_helper.print_installing_dependencies
          end
          unified_module_refs.each do |module_ref|
            # Using unless module_ref.is_base_module? because Base component module is installed when base is installed
            ComponentModule.install_or_pull?(module_ref, @prompt_helper, @print_helper) unless module_ref.is_base_module?
          end
        end
      end

      def install_with_local
        @component_module_refs.each do |component_module_ref|
          unless self.class.resolved.include?("#{component_module_ref.namespace}:#{component_module_ref.module_name}")
            self.class.add_to_resolved("#{component_module_ref.namespace}:#{component_module_ref.module_name}")
            if component_module_ref.is_master_version?
              server_response = self.class.get_server_dependencies(component_module_ref)
              if module_info = server_response.data(:module_info)
                if module_info['has_remote']
                  new_print_helper  = PrintHelper.new(:module_ref => component_module_ref, :source => :remote)
                  if @prompt_helper.pull_module_update?(new_print_helper)
                    ComponentModule.install_or_pull_new?(component_module_ref, @prompt_helper, new_print_helper) unless component_module_ref.is_base_module?
                    RemoteDependencies.install_or_pull?(component_module_ref, @prompt_helper, new_print_helper)
                  else
                    new_print_helper.print_using_installed_dependent_module
                    LocalDependencies.install_or_pull?(server_response, @prompt_helper, new_print_helper)
                  end
                else
                  # does not have remote but exist locally
                  new_print_helper = PrintHelper.new(:module_ref => component_module_ref, :source => :remote)
                  new_print_helper.print_using_installed_dependent_module

                  LocalDependencies.install_or_pull?(server_response, @prompt_helper, new_print_helper)
                end
              else
                remote_response  = nil
                new_print_helper = PrintHelper.new(:module_ref => component_module_ref, :source => :remote)
                cmp              = ComponentModule.new(component_module_ref, @prompt_helper, new_print_helper)
                if component_module_ref.module_installed?(cmp)
                  if @prompt_helper.pull_module_update?(new_print_helper)
                    ComponentModule.install_or_pull_new?(component_module_ref, @prompt_helper, new_print_helper) unless component_module_ref.is_base_module?
                  else
                    new_print_helper.print_using_installed_dependent_module
                  end
                else
                  ComponentModule.install_or_pull_new?(component_module_ref, @prompt_helper, new_print_helper) unless component_module_ref.is_base_module?
                end
              end
            else
              new_print_helper = PrintHelper.new(:module_ref => component_module_ref, :source => :remote)
              new_print_helper.print_using_installed_dependent_module
              cmp = ComponentModule.new(component_module_ref, @prompt_helper, new_print_helper)
              unless component_module_ref.module_installed?(cmp)
                ComponentModule.install_or_pull_new?(component_module_ref, @prompt_helper, new_print_helper)
              end

              server_response = self.class.get_server_dependencies(component_module_ref)
              LocalDependencies.install_or_pull?(server_response, @prompt_helper, new_print_helper)
            end
          end
        end
      end

      def self.create_module_ref(ref_hash, opts = {})
        module_ref_hash = {
          :namespace => ref_hash['namespace'], 
          :module_name => ref_hash['name'], 
          :version => ref_hash['version']
        }
        Install::ModuleRef.new(module_ref_hash)
      end

      def get_unified_dependent_module_refs
        component_dependency_tree = ComponentDependencyTree.create(@base_module_ref, @component_module_refs, @print_helper)
        # returns an array of module_refs that have been unified so only one version and namespace per module name
        component_dependency_tree.resolve_conflicts_and_versions
      end

      def get_local_modules_info
        component_dependency_tree = ComponentDependencyTree.create(@base_module_ref, @component_module_refs, @print_helper, 'local')
        component_dependency_tree.resolve_conflicts_and_versions
      end

      def self.get_server_dependencies(component_module_ref)
        hash = {
          :module_name => component_module_ref.module_name,
          :namespace   => component_module_ref.namespace,
          :version?    => component_module_ref.version
        }
        rest_get "#{BaseRoute}/module_info_with_local_dependencies", QueryStringHash.new(hash)
      end
    end
  end
end


