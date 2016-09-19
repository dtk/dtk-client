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
            :branch           => response.required(:branch, :name),
            :repo_url         => response.required(:repo, :url)
          }

          response = ClientModuleDir::GitRepo.commit_and_push_to_service_repo(push_args)
          commit_sha = response.required(:head_sha)

          response = rest_post("#{BaseRoute}/#{service_instance}/update_from_repo", :commit_sha => commit_sha)
          process_response(response, :service_instance => service_instance, :args => push_args)
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

      def self.process_response(response, opts = {})
        print_msgs_of_type(:error_msgs, response)
        print_msgs_of_type(:warning_msgs, response)
        print_msgs_of_type(:info_msgs, response)

        pull_repo_updates?(response, opts)
        process_backup_files(response, opts)
        process_semantic_diffs(response)
      end

      def self.pull_repo_updates?(response, opts = {})
        ClientModuleDir::GitRepo.pull_from_service_repo(opts[:args]) if response.data(:repo_updated)
      end

      # TODO: DTK-2663: This is fine for now, but in 0.10.1 want to move logic that writes files to be in
      # a new method we write in ClientModuleDir::GitRepo.add_file
      def self.process_backup_files(response, opts = {})
        backup_files = response.data(:backup_files) || {}
        return if backup_files.empty?
        service_instance_name = opts[:service_instance]
        final_path = "#{OsUtil.dtk_local_folder}/#{service_instance_name}" 
        
        ClientModuleDir::GitRepo.add_file(:backup_files => backup_files, :final_path => final_path)

        response = ClientModuleDir::GitRepo.commit_and_push_to_service_repo(opts[:args]) 
      end

      def self.process_semantic_diffs(response)
        semantic_diffs = response.data(:semantic_diffs) || {}
        return if semantic_diffs.empty?
        # TODO: DTK-2663; cleanup so pretty printed'
        OsUtil.print_info("\nDiffs that were pushed:")
        # TODO: get rid of use of STDOUT
        #STDOUT << hash_to_yaml(semantic_diffs).gsub("---\n", "")
        OsUtil.print(hash_to_yaml(semantic_diffs).gsub("---\n", ""))
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
