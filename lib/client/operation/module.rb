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
      OPERATIONS = [:install, :list, :list_assemblies, :push, :uninstall]
      OPERATIONS.each { |operation| require_relative("module/#{operation}") }

      BaseRoute = 'modules'

      extend ModuleServiceCommon::ClassMixin
        
      private

      def module_exists?(module_ref, opts = {})
        self.class.module_exists?(module_ref, opts)
      end

      def self.module_exists?(module_ref, opts = {})
        type = opts[:type] || :common_module
        query_string_hash = QueryStringHash.new(module_ref_hash(module_ref).merge(:module_type => type))
        response = rest_get(BaseRoute, query_string_hash)
        response.data.empty? ? nil : response
      end

      # Can be used as input hash for QueryParams and PostBody
      def self.module_ref_hash(module_ref)
        {
          :namespace   => module_ref.namespace,
          :module_name => module_ref.module_name
        }
      end

      def self.module_ref_query_string_hash(module_ref)
        QueryStringHash.new(module_ref_hash(module_ref))
      end

    end
  end
end


