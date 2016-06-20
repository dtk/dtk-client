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
  class Operation
    class Module < self
      require_relative('module/install')
      require_relative('module/push')
      require_relative('module/delete')

      BaseRoute = 'modules'

      # Args can have keys
      #  :base_dsl_file_obj - DTK::DSL::FileObj (required)
      def self.install(args = Args.new)
        Install.install(args)
      end

      def self.push(args = Args.new)
        Push.push(args)
      end

      def self.list_assemblies
        rest_get("#{BaseRoute}/list_assemblies").set_render_as_table!
      end

      # Args can have keys
      #  :module_ref - DTK::Client::ModuleRef object (required)
      def self.delete(args = Args.new)
        Delete.delete(args)
      end

      private

      def module_exists?(module_ref, type)
        self.class.module_exists?(module_ref, type)
      end
      
      def self.module_exists?(module_ref, type)
        query_params = QueryParams.new(
          :namespace   => module_ref.namespace,
          :module_name => module_ref.module_name,
        )
        response = rest_get(BaseRoute, query_params)
        # if response has key #{type}_id then a module exists and
        ! response.data("#{type}_id".to_sym).nil?
      end

    end
  end
end


