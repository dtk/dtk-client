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
    class Publish < self
      attr_reader :module_ref, :target_repo_dir, :version
      def initialize(catalog, module_ref, directory_path)
        @catalog         = catalog
        @module_ref      = module_ref
        @target_repo_dir = directory_path || module_ref.client_dir_path
        @version         = module_ref.version
      end
      private :initialize

      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          module_ref        = args.required(:module_ref)
          base_dsl_file_obj = args.required(:base_dsl_file_obj)
          directory_path    = args[:directory_path]
          new('dtkn', module_ref, directory_path).publish({file_obj: base_dsl_file_obj})
        end
      end

      def publish(opts = {})
        file_obj = opts[:file_obj]
        parsed_module = file_obj.parse_content(:common_module_summary)

        module_info = {
          name: module_ref.module_name,
          namespace: module_ref.namespace,
          version: @version,
          repo_dir: @target_repo_dir
        }

        response = DtkNetworkClient::Publish.run(module_info, parsed_module: parsed_module, development_mode: Config[:development_mode])
        OsUtil.print_info("Module '#{module_ref.pretty_print}' has been published successfully.")

        if Config[:development_mode]
          ret_response = { namespace_id: response['namespace_short_id'], module_version_id: response['short_id'] }
          return ret_response
        end

        nil
      end
    end
  end
end


