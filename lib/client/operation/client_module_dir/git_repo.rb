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

      def self.commit_and_push_to_nested_module_repo(args)
        wrap_operation(args) do |args|
          response_data_hash(:head_sha => Internal.commit_and_push_to_nested_module_repo(args))
        end
      end

      def self.clone_exists?(args)
        wrap_operation(args) do |args|
          type = args.required(:type)
          local_dir_exists?(type, args.required("#{type}_name".to_sym))
        end
      end

      def self.clone(args)
        wrap_operation(args) do |args|
          repo_url        = args.required(:repo_url)
          target_repo_dir = args.required(:target_repo_dir)
          branch          = args.required(:branch)
          response_data_hash(:target_repo_dir => Internal.clone(repo_url, target_repo_dir, branch))
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

      # The retries are put in to avoid race condition when the keys are not yet in repo manager gitolite
      DEFAULT_NUM_DTKN_FETCH_RETRIES = 20
      SLEEP_BETWEEN_RETRIES = 1
      def self.fetch_dtkn_remote(args)
        if num_retries = ENV['NUM_DTKN_FETCH_RETRIES']
          num_retries = num_retries.to_i rescue nil
        end
        num_retries ||= DEFAULT_NUM_DTKN_FETCH_RETRIES
        ret = nil
        while num_retries > 0
          num_retries -= 1
          begin
            if ret = fetch_dtkn_remote_single_try(args)
              return ret
            end
          rescue => e
            fail e if num_retries == 0
          end
        end
        ret # should not be reached
      end

      def self.fetch_dtkn_remote_single_try(args)
        wrap_operation(args) do |args|
          repo_with_remote = repo_with_dtkn_remote(args)

          repo_with_remote.fetch
          response_data_hash
        end
      end
      private_class_method :fetch_dtkn_remote_single_try

      def self.merge_from_dtkn_remote(args)
        wrap_operation(args) do |args|
          remote_branch    = args.required(:remote_branch)
          no_commit        = args[:no_commit]
          repo_with_remote = repo_with_dtkn_remote(args)
          use_theirs       = args[:use_theirs]

          response_data_hash(:head_sha => repo_with_remote.merge_from_remote(remote_branch, :no_commit => no_commit, :use_theirs => use_theirs))
        end
      end

      def self.local_ahead?(args)
        wrap_operation(args) do |args|
          remote_branch = args.required(:remote_branch)
          no_commit     = args[:no_commit]
          repo_with_remote  = repo_with_dtkn_remote(args)

          response_data_hash(:local_ahead => repo_with_remote.local_ahead?(remote_branch, :no_commit => no_commit))
        end
      end

      def self.create_empty_git_repo?(args)
        wrap_operation(args) do |args|
          repo_dir = args.required(:repo_dir)
          branch   = args.required(:branch)

          response_data_hash(:repo => Internal.create_empty_git_repo?(repo_dir, :branch => branch))
        end
      end

      # The arg repo wil have a branch. This funbctio checks that out and when finished goes back to current_branch
      def self.checkout_branch(args, &block)
        wrap_operation(args) do |args|
          repo               = args.required(:repo)
          current_branch     = args.required(:current_branch)
          branch_to_checkout = args.required(:branch_to_checkout)

          Internal.checkout_branch(repo, branch_to_checkout, :current_branch => current_branch, &block)
          response_data_hash
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

      def self.all_branches(args)
        wrap_operation(args) do |args|
          response_data_hash(:branches => Internal.all_branches(args))
        end
      end

      def self.current_branch(args)
        wrap_operation(args) do |args|
          response_data_hash(:branch => Internal.current_branch(args))
        end
      end

      def self.reset_hard(args)
        wrap_operation(args) do |args|
          remote_branch    = args.required(:remote_branch)
          repo_with_remote = repo_with_dtkn_remote(args)
          branch           = args[:branch]
          response_data_hash(:head_sha => repo_with_remote.reset_hard(remote_branch, :branch => branch))
        end
      end

      private

      def self.repo_with_dtkn_remote(args)
        info_type = args.required(:info_type)
        repo_dir  = args.required(:repo_dir)
        Internal::Dtkn.repo_with_remote(info_type, repo_dir, add_remote: args[:add_remote])
      end

    end
  end
end

