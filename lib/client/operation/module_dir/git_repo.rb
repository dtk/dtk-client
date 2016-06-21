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
  class Operation::ModuleDir
    # Operations for managing module folders that are git repos
    class GitRepo < self
      def self.fetch_merge_and_push(args)
        wrap_as_response(args) do |args|
          { :head_sha => Internal.fetch_merge_and_push(args) }
        end
      end

      def self.create_add_remote_and_push(args)
        wrap_as_response(args) do |args|
          repo_dir      = args.required(:repo_dir)
          repo_url      = args.required(:repo_url)
          remote_branch = args.required(:remote_branch)
          { :head_sha => Internal.create_add_remote_and_push(repo_dir, repo_url, remote_branch) }
        end
      end

      def self.init_and_push_from_existing_repo(args)
        wrap_as_response(args) do |args|
          repo_dir      = args.required(:repo_dir)
          repo_url      = args.required(:repo_url)
          remote_branch = args.required(:remote_branch)
          { :head_sha => Internal.init_and_push_from_existing_repo(repo_dir, repo_url, remote_branch) }
        end
      end

      def self.clone_service_repo(args)
        wrap_as_response(args) do |args|
          { :target_repo_dir => Internal.clone_service_repo(args) }
        end
      end

      private

      # All Internal do not have wrap_as_response and can only be accessed by a method that wraps it
      class Internal < self
        def self.clone_service_repo(args)
          repo_url        = args.required(:repo_url)
          module_ref      = args.required(:module_ref)
          branch          = args.required(:branch)
          service_name    = args.required(:service_name)
          
          target_repo_dir  = create_service_dir(service_name)
          begin
            git_repo.clone(repo_url, target_repo_dir,  branch)
          rescue => e
            #cleanup by deleting directory
            
            FileUtils.rm_rf(target_repo_dir) if File.directory?(target_repo_dir)
            # Log error details
            Logger.instance.error_pp(e.message, e.backtrace)
            
            # User-friendly error
            raise Error::Usage, "Clone to directory '#{target_repo_dir}' failed"
          end
          target_repo_dir
        end
        
        DTK_SERVER_REMOTE = 'dtk-server'
        LOCAL_BRANCH = 'master'
        def self.fetch_merge_and_push(args)
          repo_dir      = args.required(:repo_dir)
          repo_url      = args.required(:repo_url)
          remote_branch = args.required(:branch)
          
          head_sha =
            if git_repo.is_git_repo?(repo_dir)
              init_and_push_from_existing_repo(repo_dir, repo_url, remote_branch)
            else
              create_repo_from_remote(repo_dir, repo_url, remote_branch)
            end
          
          head_sha 
        end

        def self.create_add_remote_and_push(repo_dir, repo_url, remote_branch)
          repo = git_repo.new(repo_dir)
          add_remote_and_push(repo, repo_url, remote_branch)
          repo.head_commit_sha
        end
        

        def self.init_and_push_from_existing_repo(repo_dir, repo_url, remote_branch)
          repo = git_repo.new(repo_dir)
          
          if repo.is_there_remote?(DTK_SERVER_REMOTE)
            push_when_there_is_dtk_remote(repo, repo_dir, repo_url, remote_branch)
          else
            add_remote_and_push(repo, repo_url, remote_branch)
          end
          
          repo.head_commit_sha
        end
        
        private

        def self.push_when_there_is_dtk_remote(repo, repo_dir, repo_url, remote_branch)
          # if there is only one remote and it is dtk-server; remove .git and initialize and push as new repo to dtk-server remote
          # else if multiple remotes and dtk-server being one of them; remove dtk-server; add new dtk-server remote and push
          if repo.remotes.size == 1
            git_repo.unlink_local_clone?(repo_dir)
            create_repo_from_remote(repo_dir, repo_url, remote_branch)
          else
            repo.remove_remote(DTK_SERVER_REMOTE)
            add_remote_and_push(repo, repo_url, remote_branch)
          end
        end

        def self.create_repo_from_remote(repo_dir, repo_url, remote_branch)
          repo = git_repo.new(repo_dir, :branch => LOCAL_BRANCH)
          repo.checkout(LOCAL_BRANCH, :new_branch => true)
          repo.add_remote(DTK_SERVER_REMOTE, repo_url)
          repo.stage_and_commit
          repo.push(DTK_SERVER_REMOTE, remote_branch, { :force => true })
          repo.head_commit_sha
        end
        
        def self.add_remote_and_push(repo, repo_url, remote_branch)
          repo.add_remote(DTK_SERVER_REMOTE, repo_url)
          repo.stage_and_commit
          repo.push(DTK_SERVER_REMOTE, remote_branch, { :force => true })
        end
        
        def self.git_repo
          ::DTK::Client::GitRepo
        end
      end
    end
  end
end

