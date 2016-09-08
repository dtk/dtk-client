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
    class Stage < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          module_ref      = args.required(:module_ref)
          remove_existing = args[:remove_existing]

          post_body = PostBody.new(
            :namespace       => module_ref.namespace,
            :module_name     => module_ref.module_name,
            :assembly_name   => args.required(:assembly_name),
            :service_name?   => args[:service_name],
            :version?        => args[:version],
            :target_service? => args[:target_service],
            :is_target?      => args[:is_target]
          )
          response = rest_post("#{BaseRoute}/create", post_body)

          service_instance = response.required(:service, :name)

          clone_args = {
            :module_ref       => module_ref,
            :repo_url         => response.required(:repo, :url),
            :branch           => response.required(:branch, :name),
            :service_instance => service_instance,
            :remove_existing  => remove_existing
          } 
          message = ClientModuleDir::GitRepo.clone_service_repo(clone_args)
          target_dir = message.data(:target_repo_dir)

          OsUtil.print_info("Service instance '#{service_instance}' has been created. In order to work with service instance, please navigate to: #{target_dir}") 
        end
      end
    end
  end
end
