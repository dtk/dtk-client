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
    class Edit < self
      def self.edit(args = Args.new)
        wrap_operation(args) do |args|
          module_ref       = args.required(:module_ref)
          relative_path    = args.required(:relative_path)
          service_instance = args.required(:service_instance)
          file_obj         = args.required(:base_dsl_file_obj).raise_error_if_no_content
          file_path        = file_obj.path?

          post_body = PostBody.new(
            :service_instance => service_instance
          )
          response = rest_post("#{BaseRoute}/repo_info", post_body)

          pull_args = {
            :module_ref   => module_ref,
            :repo_url     => response.required(:repo, :url),
            :branch       => response.required(:branch, :name),
            :service_name => response.required(:service, :name),
            :file_path    => file_path
          }
          response = ClientModuleDir::GitRepo.pull_and_edit(pull_args)

          Push.push(args) if response.data[:push_needed]
        end
      end
    end
  end
end
