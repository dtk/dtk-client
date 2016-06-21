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
      def self.push(args = Args.new)
        wrap_as_response(args) do |args|
          module_ref = args.required(:module_ref)
          file_obj   = args.required(:base_dsl_file_obj).raise_error_if_no_content

          unless module_info = module_exists?(module_ref, { :type => :common_module })
            raise Error::Usage, "DTK module '#{module_ref.reference}' does not exist."
          end

          branch    = module_info.required(:branch, :name)
          repo_url  = module_info.required(:repo, :url)
          repo_name = module_info.required(:repo, :name)
          repo_dir  = parent_dir(file_obj)

          git_response = ModuleDir::GitRepo.create_add_remote_and_push(repo_dir, repo_url, branch)
          # git_response = ModuleDir::GitRepo.init_and_push_from_existing_repo(repo_dir, repo_url, branch)
          return git_response if git_response.is_a?(DTK::Client::Response) && !git_response.ok?

          post_body = PostBody.new(
            :module_name => module_info.required(:module, :name),
            :namespace   => module_info.required(:module, :namespace),
            :version?    => module_info.data['module']['version'],
            :branch      => branch,
            :repo_name   => repo_name,
            :commit_sha  => git_response
          )

          rest_post("#{BaseRoute}/update_from_repo", post_body)
          nil
        end
      end
    end
  end
end


