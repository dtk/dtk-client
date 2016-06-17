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
    class BaseModule < self
      BaseRoute = 'modules'

      def self.install(base_module_ref, components, file_obj)
        post_body = PostBody.new(
          :module_name => base_module_ref.module_name,
          :namespace   => base_module_ref.namespace,
          :version?    => base_module_ref.version
        )

        response = rest_post("#{BaseRoute}/create_empty_module", post_body)

        branch    = response.required(:branch, :name)
        repo_url  = response.required(:repo, :url)
        repo_name = response.required(:repo, :name)
        head_sha  = response.required(:branch, :head_sha)
        
        # making repo dir to be dircetory that directly holds the base file object file_obj
        repo_dir = parent_dir(file_obj)

        args = {
          :repo_dir => repo_dir,
          :repo_url => repo_url,
          :branch   => branch
        }

        ModuleDir::GitRepo.fetch_merge_and_push(args)

        post_body.merge!(
          :branch     => branch,
          :repo_name  => repo_name,
          :commit_sha => head_sha
        )

        rest_post("#{BaseRoute}/update_from_repo", post_body)
      end

      private

      def self.parent_dir(file_obj)
        unless path = file_obj.path?
          raise Error, "Unexpected that 'file_obj.path?' is nil" 
        end
        OsUtil.parent_dir(path)
      end
    end
  end
end


