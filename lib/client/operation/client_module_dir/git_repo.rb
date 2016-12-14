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
    # Operations for managing module folders that are git repos
    class GitRepo < self
      require_relative('git_repo/internal')

      def self.commit_and_push_to_service_repo(args)
        wrap_operation(args) do |args| 
          response_data_hash(:head_sha => Internal.commit_and_push_to_service_repo(args))
        end
      end

      def self.clone_exists?(args)
        wrap_operation(args) do |args|
          type = args.required(:type)
          local_dir_exists?(type, args.required("#{type}_name".to_sym))
        end
      end

      def self.clone_service_repo(args)
        wrap_operation(args) do |args|
          response_data_hash(:target_repo_dir => Internal.clone_service_repo(args))
        end
      end

      def self.clone_module_repo(args)
        wrap_operation(args) do |args|
          response_data_hash(:target_repo_dir => Internal.clone_module_repo(args))
        end
      end

      def self.create_add_remote_and_push(args)
        wrap_operation(args) do |args|
          repo_dir      = args.required(:repo_dir)
          repo_url      = args.required(:repo_url)
          remote_branch = args.required(:remote_branch)
          response_data_hash(:head_sha => Internal.create_add_remote_and_push(repo_dir, repo_url, remote_branch))
        end
      end

      def self.create_empty_repo?(args)
        wrap_operation(args) do |args|
          repo_dir  = args.required(:repo_dir)
          Internal.create_empty_git_repo?(repo_dir)
          response_data_hash
        end
      end

      def self.create_repo_with_empty_commit(args)
        wrap_operation(args) do |args|
          repo_dir   = args.required(:repo_dir)
          commit_msg = args[:commit_msg]
          repo = Internal.create_empty_git_repo?(repo_dir)
          response_data_hash(:head_sha => Internal.empty_commit(repo, commit_msg))
        end
      end

      def self.fetch_dtkn_remote(args)
        wrap_operation(args) do |args|
          repo_with_remote = repo_with_dtkn_remote(args)

          repo_with_remote.fetch
          response_data_hash
        end
      end

      def self.merge_from_dtkn_remote(args)
        wrap_operation(args) do |args|
          remote_branch = args.required(:remote_branch)
          no_commit     = args[:no_commit]
          repo_with_remote  = repo_with_dtkn_remote(args)

          response_data_hash(:head_sha => repo_with_remote.merge_from_remote(remote_branch, :no_commit => no_commit))
        end
      end

      def self.checkout_branch__return_repo(args)
        wrap_operation(args) do |args|
          repo_dir     = args.required(:repo_dir)
          local_branch = args.required(:local_branch)
          response_data_hash(:repo => Internal.checkout_branch__return_repo(repo_dir, local_branch))
        end
      end

      def self.stage_and_commit(args)
        wrap_operation(args) do |args| 
          repo_dir          = args.required(:repo_dir)
          local_branch_type = args.required(:local_branch_type)
          commit_msg        = args[:commit_msg]
          response_data_hash(:head_sha => Internal.stage_and_commit(repo_dir, local_branch_type, :commit_msg => commit_msg))
        end
      end

      def self.fetch_merge_and_push(args)
        wrap_operation(args) do |args|
          response_data_hash(:head_sha => Internal.fetch_merge_and_push(args))
        end
      end

      def self.modified(args)
        wrap_operation(args) do |args|
          response_data_hash(:modified => Internal.modified(args))
        end
      end

      def self.modified_with_diff(args)
        wrap_operation(args) do |args|
          response_data_hash(:modified => Internal.modified(args, :with_diffs => true))
        end
      end

      def self.init_and_push_from_existing_repo(args)
        wrap_operation(args) do |args|
          repo_dir      = args.required(:repo_dir)
          repo_url      = args.required(:repo_url)
          remote_branch = args.required(:remote_branch)
          response_data_hash(:head_sha => Internal.init_and_push_from_existing_repo(repo_dir, repo_url, remote_branch))
        end
      end

      def self.pull_from_remote(args)
        wrap_operation(args) do |args|
          response_data_hash(:target_repo_dir => Internal.pull_from_remote(args))
        end
      end
      
      def self.add_service_repo_file(args)
        wrap_operation(args) do |args| 
          response_data_hash(:repo => Internal.add_service_repo_file(args)) 
        end
      end

      def self.get_service_repo_file_content(args)
        wrap_operation(args) do |args| 
          response_data_hash(:content => Internal.get_service_repo_file_content(args))
        end
      end

      def self.pull_from_service_repo(args)
        wrap_operation(args) do |args| 
          response_data_hash(:repo => Internal.pull_from_service_repo(args)) 
        end
      end


      private

      def self.repo_with_dtkn_remote(args)
        info_type = args.required(:info_type)
        repo_dir  = args.required(:repo_dir)
        Internal::Dtkn.repo_with_remote(info_type, repo_dir, add_remote: args[:add_remote])
      end

      def self.response_data_hash(hash = {})
        hash.inject({}) { |h, (k, v)| h.merge(k.to_s => v) }
      end

    end
  end
end

