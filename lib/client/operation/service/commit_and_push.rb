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
          process_response(response)
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

      def self.process_response(response)
        print_msgs_of_type(:error_msgs, response)
        print_msgs_of_type(:warning_msgs, response)
        print_msgs_of_type(:info_msgs, response)

        process_backup_files(response)
        process_semantic_diffs(response)
      end

      def self.process_backup_files(response)
        backup_files = response.data(:backup_files) || {}
        return if backup_files.empty?
        pp 'TODO: DTK-2663; write code that saves each file under the service module, commits it alomng with an update if needed to .gitignore'
        pp 'DEBUG_PRINT_of_info'
        backup_files.each_pair do |file_path, content|
          pp [:file_path, file_path]
          STDOUT << content
          pp '----'
        end
      end

      def self.process_semantic_diffs(response)
        semantic_diffs = response.data(:semantic_diffs) || {}
        return if semantic_diffs.empty?
        pp 'TODO: DTK-2663; cleanup so pretty printed'
        OsUtil.print('Diffs that were pushed:')
        # TODO: get rid of use of STDOUT
        STDOUT << hash_to_yaml(semantic_diffs)
      end

      PRINT_FN = {
        :info_msgs    => lambda { |msg| OsUtil.print_info(msg) },
        :warning_msgs => lambda { |msg| OsUtil.print_warning(msg) },
        :error_msgs => lambda { |msg| OsUtil.print_error(msg) }
      }
      def self.print_msgs_of_type(msg_type, response)
        msgs = response.data(msg_type) || []
        unless msgs.empty?
          print_fn = PRINT_FN[msg_type]
          msgs.each { |msg| print_fn.call(msg) }
        end
      end
    end
  end
end
