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
    class Add < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          service_instance     = args.required(:service_instance)
          path                 = args.required(:path)
          relative_path        = args.required(:relative_path)
          service_instance_dir = args[:service_instance_dir]
          content              = FileHelper.get_content?(relative_path)

          query_string_hash = QueryStringHash.new(:service_instance => service_instance, path: path, content: content)
          response = rest_post "#{BaseRoute}/add_by_path", query_string_hash

          if path.include?('actions/')
            repo_info_args = Args.new(
              :service_instance     => service_instance,
              :commit_message       => "Updating changes to service instance '#{service_instance}'",
              :branch               => response.required(:base_module, :branch, :name),
              :repo_url             => response.required(:base_module, :repo, :url),
              :service_instance_dir => service_instance_dir
            )
            ClientModuleDir::GitRepo.pull_from_service_repo(repo_info_args)
          end

          response
        end
      end
    end
  end
end
