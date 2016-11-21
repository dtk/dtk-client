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

      def self.create_add_remote_and_pull_from_dtkn(args)
        wrap_operation(args) do |args|
          info_type     = args.required(:info_type)
          repo_dir      = args.required(:repo_dir)
          repo_url      = args.required(:repo_url)
          remote_branch = args.required(:remote_branch)

          repo = Internal.create_empty_repo(repo_dir, :branch_type => :dtkn)
          Internal.add_dtkn_remote(info_type, repo, repo_url)
          response_data_hash(:head_sha => Internal.pull_from_dtkn(info_type, repo, remote_branch))
        end
      end

      def self.fetch_merge_and_push(args)
        wrap_operation(args) do |args|
          response_data_hash(:head_sha => Internal.fetch_merge_and_push(args))
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

      def self.response_data_hash(hash)
        hash.inject({}) { |h, (k, v)| h.merge(k.to_s => v) }
      end

    end
  end
end

