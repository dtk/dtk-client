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

      BaseRoute  = "modules"
      # opts can have keys:
      #   :skip_prompt
      def initialize(base_module_ref, component_module_refs, opts = {})
        # TODO: DTK-2766: in an later release will changes this so iterating over module_refs, which could have component and service info, 
        # not just component modules
        @base_module_ref       = base_module_ref
        @component_module_refs = component_module_refs 
        @print_helper          = PrintHelper.new(:module_ref => @base_module_ref, :source => :remote)
        @prompt_helper         = PromptHelper.new(:update_all => opts[:skip_prompt], :update_none => opts[:update_none])
      end
      private :initialize

      # same args as initialize
      def self.install(*args)
        new(*args).install
      end

      def install
        @print_helper.print_getting_dependencies
        unified_module_refs = get_unified_dependent_module_refs
        unless unified_module_refs.empty?
          @print_helper.print_installing_dependencies
          unified_module_refs.each do |module_ref|
            # Using unless module_ref.is_base_module? because Base component module is installed when base is installed
            ComponentModule.install_or_pull?(module_ref, @prompt_helper, @print_helper) unless module_ref.is_base_module?
          end
        end
      end

      def get_unified_dependent_module_refs
        component_dependency_tree = ComponentDependencyTree.create(@base_module_ref, @component_module_refs, @print_helper)
        # returns an array of module_refs that have been unified so only one version and namespace per module name
        component_dependency_tree.resolve_conflicts_and_versions
      end

    end
  end
end


