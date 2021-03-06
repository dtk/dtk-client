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
    class Pull < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          service_instance = args.required(:service_instance)
          response = rest_get("#{BaseRoute}/#{service_instance}/repo_info")

          pull_args = {
            :service_instance => service_instance,
            :repo_url         => response.required(:repo, :url),
            :branch           => response.required(:branch, :name),
            :service_instance_dir => args[:service_instance_dir]
          }
          ClientModuleDir::GitRepo.pull_from_service_repo(pull_args)
        end
        nil
      end
    end
  end
end
