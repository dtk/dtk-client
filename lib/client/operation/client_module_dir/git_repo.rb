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

      def self.create_add_remote_and_pull(args)
        wrap_operation(args) do |args|
          repo_dir      = args.required(:repo_dir)
          repo_url      = args.required(:repo_url)
          remote_branch = args.required(:remote_branch)
          response_data_hash(:head_sha => Internal.create_add_remote_and_pull(repo_dir, repo_url, remote_branch))
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

      # All Internal methods do not have wrap_operation and can only be accessed by a method that wraps it
      class Internal < self
        # Git Params for dtk server
        module Dtk_Server
          GIT_REMOTE   = 'dtk-server'
        end
        # Git params for dtkn
        module Dtkn
          GIT_REMOTE   = 'dtkn'
          LOCAL_BRANCH = 'master'
        end

        # returns head_sha
        def self.commit_and_push_to_service_repo(args)
          branch           = args.required(:branch)
          remote_branch    = args[:remote_branch] || branch
          service_instance = args.required(:service_instance)
          commit_message   = args[:commit_message]

          repo_dir = ret_base_path(:service, service_instance)
          repo = git_repo.new(repo_dir, :branch => branch)
          repo.stage_and_commit
          # TODO: want to switch over to using Dtk_Server::GIT_REMOTE rather than 'origin'
          dtk_server_remote = 'origin'
          repo.push(dtk_server_remote, remote_branch)
          repo.head_commit_sha
        end

        def self.clone_service_repo(args)
          repo_url         = args.required(:repo_url)
          branch           = args.required(:branch)
          service_instance = args.required(:service_instance)
          remove_existing  = args[:remove_existing]
          repo_dir         = args[:repo_dir]

          target_repo_dir = create_service_dir(service_instance, :remove_existing => remove_existing, :path => repo_dir)
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

        def self.clone_module_repo(args)
          module_type     = args.required(:module_type)
          repo_url        = args.required(:repo_url)
          branch          = args.required(:branch)
          module_name     = args.required(:module_name)
          remove_existing = args[:remove_existing]
          repo_dir        = args[:repo_dir]

          target_repo_dir = create_module_dir(module_type, module_name, :remove_existing => remove_existing, :path => repo_dir)
          begin
            git_repo.clone(repo_url, target_repo_dir,  branch)
          rescue => e
            FileUtils.rm_rf(target_repo_dir) if File.directory?(target_repo_dir)
            Logger.instance.error_pp(e.message, e.backtrace)

            raise Error::Usage, "Clone to directory '#{target_repo_dir}' failed"
          end

          target_repo_dir
        end
        
        def self.fetch_merge_and_push(args)
          repo_dir      = args.required(:repo_dir)
          repo_url      = args.required(:repo_url)
          remote_branch = args.required(:branch)
          
          head_sha =
            if git_repo.is_git_repo?(repo_dir)
              init_and_push_from_existing_repo(repo_dir, repo_url, remote_branch)
            else
              create_repo_from_remote_and_push(repo_dir, repo_url, remote_branch)
            end
          
          head_sha 
        end
        
        def self.create_add_remote_and_push(repo_dir, repo_url, remote_branch)
          repo = git_repo.new(repo_dir)
          add_remote_and_push(repo, repo_url, remote_branch)
          repo.head_commit_sha
        end

        def self.create_add_remote_and_pull(repo_dir, repo_url, remote_branch)
          repo = create_repo_from_dtkn_remote(repo_dir, repo_url, remote_branch)
          add_dtkn_remote_and_pull(repo, repo_url, remote_branch)
          repo.head_commit_sha
        end
        
        def self.init_and_push_from_existing_repo(repo_dir, repo_url, remote_branch)
          repo = git_repo.new(repo_dir)
          
          if repo.is_there_remote?(Dtk_Server::GIT_REMOTE)
            push_when_there_is_dtk_remote(repo, repo_dir, repo_url, remote_branch)
          else
            add_remote_and_push(repo, repo_url, remote_branch)
          end
          
          repo.head_commit_sha
        end
        
        def self.pull_from_remote(args)
          repo_url       = args.required(:repo_url)
          remote_branch  = args.required(:branch)
          repo_dir       = args.required(:repo_dir)
          
          repo = git_repo.new(repo_dir, :branch => remote_branch)
          repo.pull(repo.remotes.first, remote_branch)
        end
        
        # returns the repo
        def self.pull_from_service_repo(args)
          repo_url         = args.required(:repo_url)
          remote_branch    = args.required(:branch)
          service_instance = args.required(:service_instance)
          
          repo_dir = ret_base_path(:service, service_instance)
          repo = git_repo.new(repo_dir, :branch => remote_branch)
          
          repo.pull(repo.remotes.first, remote_branch)
          repo
        end

        def self.push_when_there_is_dtk_remote(repo, repo_dir, repo_url, remote_branch)
          # if there is only one remote and it is dtk-server; remove .git and initialize and push as new repo to dtk-server remote
          # else if multiple remotes and dtk-server being one of them; remove dtk-server; add new dtk-server remote and push
          if repo.remotes.size == 1
            git_repo.unlink_local_clone?(repo_dir)
            create_repo_from_remote_and_push(repo_dir, repo_url, remote_branch)
          else
            repo.remove_remote(Dtk_Server::GIT_REMOTE)
            add_remote_and_push(repo, repo_url, remote_branch)
          end
        end

        def self.create_repo_from_server_remote(repo_dir, repo_url, remote_branch)
          repo = git_repo.new(repo_dir, :branch => Dtkn::LOCAL_BRANCH)
          repo.checkout(Dtkn::LOCAL_BRANCH, :new_branch => true)
          repo.add_remote(Dtk_Server::GIT_REMOTE, repo_url)
          repo
        end

        def self.create_repo_from_dtkn_remote(repo_dir, repo_url, remote_branch)
          repo = git_repo.new(repo_dir, :branch => Dtkn::LOCAL_BRANCH)
          repo.checkout(Dtkn::LOCAL_BRANCH, :new_branch => true)
          repo.stage_and_commit
          repo.add_remote(Dtkn::GIT_REMOTE, repo_url)
          repo
        end

        def self.create_repo_from_remote_and_push(repo_dir, repo_url, remote_branch)
          repo = create_repo_from_server_remote(repo_dir, repo_url, remote_branch)
          # repo = git_repo.new(repo_dir, :branch => Dtkn::LOCAL_BRANCH)
          # repo.checkout(Dtkn::LOCAL_BRANCH, :new_branch => true)
          # repo.add_remote(Dtk_Server::GIT_REMOTE, repo_url)
          repo.stage_and_commit
          repo.push(Dtk_Server::GIT_REMOTE, remote_branch, { :force => true })
          repo.head_commit_sha
        end
        
        def self.add_remote_and_push(repo, repo_url, remote_branch)
          repo.add_remote(Dtk_Server::GIT_REMOTE, repo_url)
          repo.stage_and_commit
          repo.push(Dtk_Server::GIT_REMOTE, remote_branch, { :force => true })
        end

        def self.add_dtkn_remote_and_pull(repo, repo_url, remote_branch)
          repo.add_remote(Dtkn::GIT_REMOTE, repo_url)
          repo.pull(Dtkn::GIT_REMOTE, remote_branch)
        end
        
        def self.add_service_repo_file(args)
          branch           = args.required(:branch)
          service_instance = args.required(:service_instance)
          path             = args.required(:path)
          content          = args.required(:content)
          checkout_branch(service_instance, branch) do
            File.open(qualified_path(service_instance, path), 'w') { |f| f.write(content) }
          end
        end

        # returns content if file exists
        def self.get_service_repo_file_content(args)
          branch           = args.required(:branch)
          service_instance = args.required(:service_instance)
          path             = args.required(:path)
          checkout_branch(service_instance, branch) do
            qualified_path = qualified_path(service_instance, path)
            if File.exists?(qualified_path)
              File.open(qualified_path, 'r').read
            end
          end
        end

        def self.git_repo
          ::DTK::Client::GitRepo
        end

        private

        # relative_path is relative to top-leel repo directory
        def self.qualified_path(service_instance, relative_path)
          repo_dir = ret_base_path(:service, service_instance)
          "#{repo_dir}/#{relative_path}"
        end

        CHECKOUT_LOCK = Mutex.new
        def self.checkout_branch(service_instance, branch, &body)
          ret = nil
          CHECKOUT_LOCK.synchronize do
            repo = git_repo.new(ret_base_path(:service, service_instance), :branch => branch)
            current_branch = repo.current_branch.name
            if current_branch == branch
              ret = yield
            else
              begin
                repo.checkout(branch) 
                ret = yield
              ensure
                repo.checkout(current_branch)
              end
            end
          end
          ret
        end

      end
    end
  end
end

