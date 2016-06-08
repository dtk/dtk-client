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
      def self.create_clone(args = Args.new)
        wrap_as_response(args) do |args|
          repo_url        = args.required(:repo_url)
          module_dir_type = args.required(:module_dir_type)
          module_ref      = args.required(:module_ref)
          branch          = args.required(:branch)
          create_clone_aux(module_dir_type, module_ref, repo_url, branch)
        end
      end
      
      private
      
      def self.create_clone_aux(module_dir_type, module_ref, repo_url, branch)
        pp [:d2, module_dir_type, module_ref, repo_url, branch]
        raise Error::Usage.new('got here')
        target_repo_dir = create_module_dir(module_dir_type, module_ref)
        
        begin
          opts_clone = (opts[:track_remote_branch] ? {:track_remote_branch => true} : {})
          GitAdapter.clone(repo_url, target_repo_dir, branch, opts_clone)
        rescue => e
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


