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
    class CreateWorkspace < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          post_body = PostBody.new(
            :workspace_name? => args[:workspace_name],
            :target_service? => args[:target_service]
          )
          response = rest_post("#{BaseRoute}/create_workspace", post_body)

          workspace_name = response.required(:workspace, :name)
          ClientModuleDir.create_service_dir(workspace_name)

          response
        end
      end
    end
  end
end
