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
  class Operation::Module
    class Push < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          module_ref = args.required(:module_ref)

          unless client_dir_path = module_ref.client_dir_path
            raise Error, "Not implemented yet; need to make sure module_ref.client_dir_path is set when client_dir_path given"
          end

          unless module_info = module_exists?(module_ref, :type => :common_module)
            raise Error::Usage, "DTK module '#{module_ref.print_form}' does not exist."
          end

          branch    = module_info.required(:branch, :name)
          repo_url  = module_info.required(:repo, :url)
          repo_name = module_info.required(:repo, :name)

          git_repo_args = {
            :repo_dir      => module_ref.client_dir_path,
            :repo_url      => repo_url,
            :remote_branch => branch
          }
          git_repo_response = ClientModuleDir::GitRepo.create_add_remote_and_push(git_repo_args)
          # TODO: do we want below instead of above?
          # git_repo_response = ClientModuleDir::GitRepo.init_and_push_from_existing_repo(git_repo_args)

          post_body = PostBody.new(
            :module_name => module_info.required(:module, :name),
            :namespace   => module_info.required(:module, :namespace),
            :version?    => module_info.index_data(:module, :version),
            :repo_name   => repo_name,
            :commit_sha  => git_repo_response.data(:head_sha)
          )

          rest_post("#{BaseRoute}/update_from_repo", post_body)
          nil
        end
      end
    end
  end
end


