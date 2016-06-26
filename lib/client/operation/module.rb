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

      def self.install(args = Args.new)
        Install.install(args)
      end

      def self.push(args = Args.new)
        Push.push(args)
      end

      def self.list_assemblies
        rest_get("#{BaseRoute}/list_assemblies").set_render_as_table!
      end

      def self.delete(args = Args.new)
        Delete.delete(args)
      end

      def self.parent_dir(file_obj)
        unless path = file_obj.path?
          raise Error, "Unexpected that 'file_obj.path?' is nil"
        end
        OsUtil.parent_dir(path)
      end

      private

      def module_exists?(module_ref, opts = {})
        self.class.module_exists?(module_ref, opts)
      end

      def self.module_exists?(module_ref, opts = {})
        type = opts[:type] || :common_module
        query_params = QueryParams.new(
          :namespace   => module_ref.namespace,
          :module_name => module_ref.module_name,
          :module_type => type
        )
        response = rest_get(BaseRoute, query_params)
        response.data.empty? ? nil : response
      end

    end
  end
end


