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
  class Operation::Service
    class Eject < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          service_instance = args.required(:service_instance)
          component_ref    = args.required(:component_ref)
          directory_path   = args[:directory_path]

          post_body = PostBody.new(
            :service_instance => service_instance,
            :component_ref => component_ref
          )
          response = rest_post("#{BaseRoute}/#{service_instance}/eject", post_body)

          if repo_updated = response.data["repo_updated"] 
            repo_info_args = Args.new(
              :service_instance => service_instance,
              :branch           => response.required(:branch, :name),
              :repo_url         => response.required(:repo, :url)
            )

            ClientModuleDir::GitRepo.pull_from_service_repo(repo_info_args)
          end

          nil
        end
      end
    end
  end
end
