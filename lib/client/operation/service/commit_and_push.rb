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

          nested_module_args = Args.new(
            :service_instance     => service_instance,
            :base_module          => nil,
            :nested_modules       => nil,
            :service_instance_dir => args[:service_instance_dir]
          )
          nested_modules_response = ClientModuleDir::ServiceInstance.commit_and_push_nested_modules(nested_module_args)
          updated_nested_modules  = nested_modules_response.data(:nested_modules)

          unless updated_nested_modules.empty?
            repo_dir = (args[:service_instance_dir] || ClientModuleDir.ret_base_path(:service, service_instance))
            empty_commit_args = Args.new(
              :repo_dir   => repo_dir,
              :commit_msg => "Nested modules changed"
            )
            ClientModuleDir::GitRepo.create_repo_with_empty_commit(empty_commit_args)

            # this is used to pick up changes made in nested modules
            Dir.glob("#{repo_dir}/.nested_modules_changed_*").each { |file| File.delete(file)}
            Operation::ClientModuleDir.create_file_with_content("#{repo_dir}/.nested_modules_changed_#{Time.now.to_i}", Time.now.to_i)
          end

          repo_info_args = Args.new(
            :service_instance     => service_instance,
            :commit_message       => args[:commit_message] || default_commit_message(service_instance),
            :branch               => response.required(:branch, :name),
            :repo_url             => response.required(:repo, :url),
            :service_instance_dir => args[:service_instance_dir]
          )
          response = ClientModuleDir::GitRepo.commit_and_push_to_service_repo(repo_info_args)
          commit_sha = response.required(:head_sha)

          response = rest_post("#{BaseRoute}/#{service_instance}/update_from_repo", { :commit_sha => commit_sha, :updated_nested_modules => updated_nested_modules })
          print_msgs_of_type(:error_msgs, response)
          print_msgs_of_type(:warning_msgs, response)
          print_msgs_of_type(:info_msgs, response)

          ClientModuleDir::GitRepo.pull_from_service_repo(repo_info_args) if response.data(:repo_updated)
          if nested_module_args[:nested_modules_to_delete] = response.data['module_refs_to_delete']
            ClientModuleDir::ServiceInstance.remove_nested_module_dirs(nested_module_args)
          end
          process_backup_files(repo_info_args, response.data(:backup_files))
          process_semantic_diffs(response.data(:semantic_diffs))
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


      def self.process_backup_files(repo_info_args, backup_files)
        return if (backup_files || {}).empty?
        backup_files.each_pair do |path, content|
          ClientModuleDir::GitRepo.add_service_repo_file(repo_info_args.merge(:path => path, :content => content))
        end
    
        backup_file_paths = backup_files.keys
        update_gitignore?(repo_info_args, backup_file_paths)

        ClientModuleDir::GitRepo.commit_and_push_to_service_repo(repo_info_args)
      end

      GITIGNORE_REL_PATH = '.gitignore'
      def self.update_gitignore?(repo_info_args, backup_file_paths)
        response = ClientModuleDir::GitRepo.get_service_repo_file_content(repo_info_args.merge(:path => GITIGNORE_REL_PATH))
        gitignore_content = response.data(:content) || ''
        gitignore_files = gitignore_content.split("\n")
        to_add = ''
        backup_file_paths.each do |backup_file_path|
          to_add << "#{backup_file_path}\n" unless gitignore_files.include?(backup_file_path)
        end
        unless to_add.empty?
          gitignore_content << "\n" unless gitignore_content.empty? or gitignore_content[-1] == "\n"
          gitignore_content << to_add
          ClientModuleDir::GitRepo.add_service_repo_file(repo_info_args.merge(:path => GITIGNORE_REL_PATH, :content => gitignore_content))
        end
      end
      
      def self.process_semantic_diffs(semantic_diffs)
        return if (semantic_diffs || {}).empty?
        # TODO: DTK-2663; cleanup so pretty printed'
        OsUtil.print_info("\nDiffs that were pushed:")
        # TODO: get rid of use of STDOUT
        #STDOUT << hash_to_yaml(semantic_diffs).gsub("---\n", "")
        OsUtil.print(hash_to_yaml(semantic_diffs).gsub("---\n", ""))
      end

      PRINT_FN = {
        :info_msgs    => lambda { |msg| OsUtil.print_info(msg) },
        :warning_msgs => lambda { |msg| OsUtil.print_warning(msg) },
        :error_msgs   => lambda { |msg| OsUtil.print_error(msg) }
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
