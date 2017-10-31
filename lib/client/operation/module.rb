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
      OPERATIONS = [
        :clone_module,
        :delete_from_remote,
        :install,
        :install_from_catalog,
        :list,
        :list_assemblies,
        :list_remotes,
        :publish,
        :pull_dtkn,
        :push,
        :push_dtkn,
        :stage,
        :uninstall
      ]
      OPERATIONS.each { |operation| require_relative("module/#{operation}") }

      BaseRoute = 'modules'

      extend ModuleServiceCommon::ClassMixin
        
      private

      # opts can have keys
      #   :remote_info - Boolean
      #   :type
      #   :rsa_pub_key
      def module_version_exists?(module_ref, opts = {})
        self.class.module_version_exists?(module_ref, opts)
      end
      def self.module_version_exists?(module_ref, opts = {})
        type = opts[:type] || :common_module
        query_string_hash = module_ref_query_string_hash(module_ref, module_type: type)

        if ret_remote_info = opts[:remote_info]
          query_string_hash = query_string_hash.merge(:remote_info => ret_remote_info, :rsa_pub_key => opts[:rsa_pub_key])
        end

        response = rest_get(BaseRoute, query_string_hash)
        response.data.empty? ? nil : response
      end

      def self.module_ref_post_body(module_ref)
        PostBody.new(module_ref_hash(module_ref))
      end

      # opts can have keys:
      #    :module_type
      def self.module_ref_query_string_hash(module_ref, opts = {})
        QueryStringHash.new(module_ref_hash(module_ref, opts))
      end

      # opts can have keys:
      #    :module_type
      # Can be used as input hash for QueryParams and PostBody
      def self.module_ref_hash(module_ref, opts = {})
        {
          :namespace    => module_ref.namespace,
          :module_name  => module_ref.module_name,
          :version?     => module_ref.version,
          :module_type? => opts[:module_type]
        }
      end

    end
  end
end


