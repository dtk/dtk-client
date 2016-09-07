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
    class CommitAndPush < self
      # Commits and pushes from service instance directory
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          service_instance = args.required(:service_instance)

          response = rest_get("#{BaseRoute}/#{service_instance}/repo_info")

          push_args = {
            :service_instance => service_instance,
            :commit_message   => args[:commit_message] || default_commit_message(service_instance),
            :branch           => response.required(:branch, :name)
          }

          response = ClientModuleDir::GitRepo.commit_and_push_to_service_repo(push_args)
          commit_sha = response.required(:head_sha)

          response = rest_post("#{BaseRoute}/#{service_instance}/update_from_repo", :commit_sha => commit_sha)
          if !response.data(:warning_msgs).empty?
            response.data(:warning_msgs).each { |warning_msg| OsUtil.print_warning(warning_msg) }
          end

          if response.data(:repo_updated)
            # TODO: code to pull repo info
          end
          nil
        end
      end

      private

      def self.default_commit_message(service_instance)
        "Updating changes to service instance '#{service_instance}'"
      end

      def self.head_commit_sha(service_instance)
        raise Error, "Need to write"
      end
    end
  end
end


