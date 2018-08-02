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
  class Operation::Service
    class PromoteModuleUpdates < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          service_instance = args.required(:service_instance)
          module_name      = args.required(:module_name)

          modified_args = Args.new(
            :dir => args[:directory_path],
            :error_msg => "To allow #{args[:command]} to go through, invoke 'dtk push' to push the changes to server before invoking #{args[:command]} again",
            :command => args[:command]
          )
          ClientModuleDir::ServiceInstance.modified_service_instance_or_nested_modules?(modified_args)

          query_string_hash = QueryStringHash.new(
            service_instance: service_instance,
            module_name: module_name
          )
          rest_post "#{BaseRoute}/promote_module_updates", query_string_hash
          OsUtil.print("Base module '#{module_name}' has been updated successfully!", :yellow)
        end
      end
    end
  end
end