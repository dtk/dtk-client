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

      def self.add_remote_and_push(args)
        wrap_as_response(args) do |args|
          add_remote_and_push_aux(args)
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
          # Log error detaails
          Logger.instance.error_pp(e.message, e.backtrace)
          
          # User-friendly error
          raise Error::Usage, "Clone to directory '#{target_repo_dir}' failed"
        end
        target_repo_dir
      end

      def self.add_remote_and_push_aux(args)
        repo_dir = args.required(:repo_dir)
        repo_url = args.required(:repo_url)
        repo = git.create(repo_dir)
        repo.add_remote('origin', repo_url)
      end
    end

    private
    
    def self.git_repo
      ::DTK::Client::GitRepo
    end
  end
end


