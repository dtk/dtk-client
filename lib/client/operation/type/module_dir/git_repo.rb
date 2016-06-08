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
          clone_service_repo_aux(args)
        end
      end
      
      private

      def self.git
        ::DTK::Client::GitRepo
      end
      
      def self.clone_service_repo_aux(args)
        repo_url        = args.required(:repo_url)
        module_ref      = args.required(:module_ref)
        branch          = args.required(:branch)
        service_name    = args.required(:service_name)

        target_repo_dir  = create_service_dir(service_name)
        begin
          git.clone(repo_url, target_repo_dir,  branch)
        rescue => e

          raise Error::Usage.new('got here')        

          # Handling Git error messages with more user friendly messages
          e = GitErrorHandler.handle(e)
          
          #cleanup by deleting directory
          FileUtils.rm_rf(target_repo_dir) if File.directory?(target_repo_dir)
          error_msg = "Clone to directory (#{target_repo_dir}) failed"
          
          DtkLogger.instance.error_pp(e.message, e.backtrace)
          
          raise ErrorUsage.new(error_msg, :log_error => false)
        end
        {"module_directory" => target_repo_dir}
      end
    end

  end
end


