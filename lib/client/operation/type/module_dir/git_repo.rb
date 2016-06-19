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
      def self.clone_service_repo(args)
        wrap_as_response(args) do |args|
          { :target_repo_dir => clone_service_repo_aux(args) }
        end
      end

      def self.fetch_merge_and_push(args)
        wrap_as_response(args) do |args|
          fetch_merge_and_push_aux(args)
        end
      end
      
      private
      
      def self.clone_service_repo_aux(args)
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
      def self.fetch_merge_and_push_aux(args)
        repo_dir      = args.required(:repo_dir)
        repo_url      = args.required(:repo_url)
        remote_branch = args.required(:branch)
        
        if git_repo.is_git_repo?(repo_dir)
          # TODO: DTK-2554: Aldin needs to be written
          # There are three cases here: 
          # 1) where it is a (stale) git repo that points to just the dtk server; this probaly should be cleaned up when
          #    delete module; although this can stil happen because there can be clones on multiple machines
          #    can detect this case by seeing if it has a remote to DTK_SERVER_REMOTE
          #    This case should be handled just like create_repo_from_remote aside from first deleting the .git directory
          # 2) has one or more remotes, none of them is DTK_SERVER_REMOTE
          #    This can be handled just like create_repo_from_remote, 
          #    but rather than creating the git repo we need to initialize from it
          # 3) has two or more remotes, one of them being DTK_SERVER_REMOTE
          #    This can be handled handled by removing the remote DTK_SERVER_REMOTE
          #    and following steps for 2
          raise Error, "Needs to be written: case when installing in directory that is a git repo"
        else
          create_repo_from_remote(repo_dir, repo_url, remote_branch)
        end
      end

      def self.create_repo_from_remote(repo_dir, repo_url, remote_branch)
        repo = git_repo.create(repo_dir, :branch => LOCAL_BRANCH)
        repo.checkout(LOCAL_BRANCH, :new_branch => true) 
        repo.add_remote(DTK_SERVER_REMOTE, repo_url)
        repo.stage_and_commit
        repo.push(DTK_SERVER_REMOTE, remote_branch)
      end

      def self.git_repo
        ::DTK::Client::GitRepo
      end
    end
  end
end


