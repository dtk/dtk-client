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
  class Operation::Module::Install
    class CommonModule < self
      BaseRoute = 'modules'

      # opts can have keys:
      #   :has_remote_repo
      def self.install(module_ref, file_obj, opts = {})
        common_post_body = PostBody.new(
          :module_name => module_ref.module_name,
          :namespace   => module_ref.namespace,
          :version?    => module_ref.version
        )

        create_post_body = common_post_body.merge(:has_remote_repo? => opts[:has_remote_repo]) 
        response = rest_post("#{BaseRoute}/create_empty_module", create_post_body)

        branch    = response.required(:branch, :name)
        repo_url  = response.required(:repo, :url)

        repo_dir = file_obj.parent_dir # repo dir is directory that directly holds the base file object file_obj
        git_response = ClientModuleDir::GitRepo.fetch_merge_and_push(:repo_dir => repo_dir, :repo_url => repo_url, :branch => branch)
        commit_sha     = git_response.data(:head_sha)
        rest_post("#{BaseRoute}/update_from_repo", common_post_body.merge(:commit_sha => commit_sha, :initial_update => true))
      end
    end
  end
end


