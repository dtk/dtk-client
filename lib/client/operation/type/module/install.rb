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
      require_relative('install/component_module')

      def self.install(args = Args.new)
        wrap_as_response(args) do |args|
          file_obj = args.required(:base_dsl_file_obj).raise_error_if_no_content
          parsed_output = ::DTK::DSL::FileParser.parse_content(:base_module, file_obj)
          new(parsed_output, file_obj).install
        end
      end
      
      def install
        unless base_module_ref = get_base_module_ref?
          raise Error::Usage, "No base module reference #{dsl_path_ref}"
        end

        if base_module_exists?(base_module_ref)
          raise Error::Usage, "Module #{base_module_ref.reference} exists already"
        end

        ComponentModule.install_modules(dependent_modules)

        install_service_module(base_module_ref)

        nil
      end
      
      private
      
      def initialize(parsed_output, file_obj)
        @parsed_output = parsed_output
        @file_obj      = file_obj
      end
      
      def install_service_module(base_module_ref)
      end
      
      def get_base_module_ref?
        namespace   = @parsed_output[:namespace]
        module_name = @parsed_output[:module_name]
        if namespace and module_name
          ModuleRef.new(:namespace => namespace, :module_name => module_name, :version => @parsed_output[:version])
        end
      end
      
      def base_module_exists?(module_ref)
        query_params = QueryParams.new(
          :namespace   => module_ref.namespace,
          :module_name => module_ref.module_name,
          :version?    => module_ref.version
        )
        response = rest_get(BaseRoute, query_params)
        # if response has key :service_module_id then a service module exists and
        # an error is thrown
        ! response.data(:service_module_id).nil?
      end

      def dependent_modules
        (@parsed_output[:dependent_modules] || []).map { |module_ref_hash| ModuleRef.new(module_ref_hash) }
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


