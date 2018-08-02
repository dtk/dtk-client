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
  class Operation::ClientModuleDir
    # Operations for managing service instance folder content
    class ServiceInstance < self
      require_relative('service_instance/internal')
      def self.clone(args)
        wrap_operation(args) do |args|
          response_data_hash(:target_repo_dir => Internal.clone(args))
        end
      end

      def self.commit_and_push_nested_modules(args)
        wrap_operation(args) do |args|
          response_data_hash(:nested_modules => Internal.commit_and_push_nested_modules(args))
        end
      end

      def self.clone_nested_modules(args)
        wrap_operation(args) do |args|
          response_data_hash(:target_repo_dir => Internal.clone_nested_modules(args))
        end
      end

      def self.modified_service_instance_or_nested_modules?(args)
        wrap_operation(args) do |args|
          response_data_hash(:modified => Internal.modified_service_instance_or_nested_modules?(args))
        end
      end
    end
  end
end
