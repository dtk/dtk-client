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
module DTK::Client; class Operation::Module
  class Install::DependentModules::ComponentDependencyTree
    class ResolveModules
      def initialize(parent, opts = {})
        @print_helper    = parent.print_helper
        @base_module_ref = parent.module_ref
        @cache           = parent.cache
        @opts            = opts
      end
      private :initialize

      def self.resolve_conflicts(parent, opts = {})
        new(parent, opts).resolve_conflicts
      end
      def resolve_conflicts
        # TODO: change this simplistic method which does not take into accunt the nested structure.
        ret = []
        @cache.all_modules_refs.each do |module_ref|
          # For legacy; removing self references
          if @base_module_ref.same_module?(module_ref)
            process_when_base_module(module_ref)
          else
            process_module_ref!(ret, module_ref)
          end
        end
        ret
      end

      private

      def process_when_base_module(module_ref)
        if @base_module_ref.exact_match?(module_ref)
          @print_helper.print_warning("Removing dependency '#{module_ref.pretty_print}' that referred to base module") unless @opts[:do_not_print]
        else
          @print_helper.print_warning("Removing conflicting dependency '#{module_ref.pretty_print}' that referred to base module '#{@base_module_ref.pretty_print}'")
        end
      end

      def process_module_ref!(ret, module_ref)
        matching_module_ref = ret.find { |selected_module_ref|  module_ref.same_module?(selected_module_ref) }
        unless matching_module_ref
          ret << module_ref
        else
          unless module_ref.exact_match?(matching_module_ref)
            # TODO: DTK-2766: handle conflicts, initially by ignoring, but printing message about conflct and what is chosen
            #       more advanced could replace what is in ret and choose modules_ref over it
          end
        end
      end
      
    end
  end
end; end
