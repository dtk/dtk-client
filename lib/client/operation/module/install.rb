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
      require_relative('install/module_ref')
      require_relative('install/external_module')
      require_relative('install/common_module')

      def self.install(args = Args.new)
        wrap_as_response(args) do |args|
          file_obj = args.required(:base_dsl_file_obj).raise_error_if_no_content
          new(file_obj).install
        end
      end
      
      def install
        unless common_module_ref = get_common_module_ref?
          raise Error::Usage, "No base module reference #{dsl_path_ref}"
        end

        if module_exists?(common_module_ref, { :type => :common_module })
          raise Error::Usage, "Module #{common_module_ref.reference} exists already"
        end

        ExternalModule.install_dependent_modules(dependent_modules)
        CommonModule.install(common_module_ref, components, @file_obj)
        nil
      end
      
      private

      def initialize(file_obj)      
        @file_obj      = file_obj
        @parsed_module = file_obj.parse_content(:common_module_summary)
      end

      def get_common_module_ref?
        namespace   = @parsed_module.val(:Namespace)
        module_name = @parsed_module.val(:ModuleName)
        version     = @parsed_module.val(:ModuleVersion)
        if namespace and module_name
          ModuleRef.new(:namespace => namespace, :module_name => module_name, :version => version)
        end
      end
      
      def dependent_modules
        @dependent_modules ||= (@parsed_module.val(:DependentModules) || []).map { |module_ref_hash| ModuleRef.new(module_ref_hash) }
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


