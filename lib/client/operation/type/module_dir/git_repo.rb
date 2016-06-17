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
          raise Error, "DTK-2554: Aldin needs to be written"
        else
          repo = git_repo.create(repo_dir, :branch => LOCAL_BRANCH)
          repo.checkout(LOCAL_BRANCH, :new_branch => true) 
          repo.add_remote(DTK_SERVER_REMOTE, repo_url)
          repo.fetch(DTK_SERVER_REMOTE)
          repo.merge("#{DTK_SERVER_REMOTE}/#{remote_branch}")
          repo.stage_and_commit
          repo.push(DTK_SERVER_REMOTE, remote_branch)
        end
      end
      
      # TODO: DTK-2554: Aldin: took out your code but kept in here so you can reuse if you want
      # TODO: Aldin - will probably need to make more generic (provide remote, etc ...)          
      # def self.add_remote_and_push_aux(args)
      #  repo_dir = args.required(:repo_dir)
      #  repo_url = args.required(:repo_url)
      #  branch   = args.required(:branch)
      
      #  repo = git_repo.create(repo_dir)
      #  repo.stage_and_commit
      #  repo.add_remote(DTK_SERVER_REMOTE, repo_url)
      #  repo.push(DTK_SERVER_REMOTE, branch)
      
      def self.git_repo
        ::DTK::Client::GitRepo
      end
    end
  end
end


