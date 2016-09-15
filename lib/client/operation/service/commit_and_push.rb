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

        process_backup_files(response, opts)
        process_semantic_diffs(response)
      end

      # TODO: DTK-2663: This is fine for now, but in 0.10.1 want to move logic that writes files to be in
      # a new method we write in ClientModuleDir::GitRepo.add_file
      def self.process_backup_files(response, opts = {})
        backup_files = response.data(:backup_files) || {}
        return if backup_files.empty?

        service_instance_name = opts[:service_instance]
        final_path = "#{OsUtil.dtk_local_folder}/service/#{service_instance_name}"
        all_backup_file_paths = backup_files.keys

        if File.exists?(file_path = "#{final_path}/.gitignore")
         has_backup = false
         file = File.open(file_path, "r") do |f|
           f.each_line do |line|
             unless all_backup_file_paths.include?(line.strip)
               write = File.open(file_path, "a")
               write << line
             end
           end
         end
        else
         File.open(".gitignore", "w") do |f|
          all_backup_file_paths.each {|el| f.puts("#{el}\n")}
         end
        end

        backup_files.each_pair do |file_path, content|
          File.open("#{final_path}/#{file_path}", "a") {|f| f.write(content)}
          File.open("#{final_path}/dtk.service.yaml", "w") {|f| f.write(content)}
          # TODO: DTK-2663; write code that saves the content given by 'content' under 'file_path' which is a path relative to the service instance module. 
        end
        response = ClientModuleDir::GitRepo.commit_and_push_to_service_repo(opts[:args]) 

        # TODO: DTK-2663; write code that creates or updates .gitignore so that each file in all_backup_file_paths is aline in gitignore
        # TODO: write code that commits these changes to the service instance module.  
      end

      def self.process_semantic_diffs(response)
        semantic_diffs = response.data(:semantic_diffs) || {}
        return if semantic_diffs.empty?
        # TODO: DTK-2663; cleanup so pretty printed'
        OsUtil.print_info("\nDiffs that were pushed:")
        # TODO: get rid of use of STDOUT
        STDOUT << hash_to_yaml(semantic_diffs).gsub("---\n", "")
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
