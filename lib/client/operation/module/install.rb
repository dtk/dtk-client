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
  class Operation::Module
    class Install < self
      require_relative('install/external_module')
      require_relative('install/common_module')

      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          base_module_ref = args.required(:module_ref)
          file_obj = args.required(:base_dsl_file_obj).raise_error_if_no_content
          new(file_obj, base_module_ref).install
        end
      end
      
      def install
        unless @base_module_ref
          raise Error::Usage, "No base module reference #{dsl_path_ref}"
        end

        if module_exists?(@base_module_ref, { :type => :common_module })
          raise Error::Usage, "Module #{@base_module_ref.print_form} exists already"
        end

        unless dependent_modules.empty?
          OsUtil.print_info('Auto-importing missing dependencies')
          ExternalModule.install_dependent_modules(dependent_modules)
        end

        CommonModule.install(@base_module_ref, components, @file_obj)
        nil
      end
      
      private

      def initialize(file_obj, module_ref)      
        @file_obj         = file_obj
        @base_module_ref  = module_ref
        @parsed_module    = file_obj.parse_content(:common_module_summary)
      end

      def dependent_modules
        @dependent_modules ||= compute_dependent_modules
      end

      def compute_dependent_modules
        (@parsed_module.val(:DependentModules) || []).map do |parsed_module_ref| 
          namespace   = parsed_module_ref.req(:Namespace)
          module_name = parsed_module_ref.req(:ModuleName)
          ModuleRef.new(:namespace => namespace, :module_name => module_name)
        end
      end

      def components
        # TODO: check if we can use @parsed_module instead of @file_obj.yaml_parse_hash
        @components ||= (@file_obj.yaml_parse_hash||{})['components']
      end

      def dsl_path_ref
        if path = @file_obj.path?
          "in the dsl file '#{path}'"
        else
          "in the dsl file"
        end
      end
    end
  end
end


