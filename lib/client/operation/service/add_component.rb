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
    class AddComponent < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          service_instance     = args.required(:service_instance)
          component_ref        = args.required(:component_ref)
          version              = args[:version]
          namespace            = args[:namespace]
          parent_node          = args[:parent_node]
          service_instance_dir = args[:service_instance_dir]

          query_string_hash = QueryStringHash.new(service_instance: service_instance, component_ref: component_ref, version: version, namespace: namespace, parent_node: parent_node)
          response = rest_post "#{BaseRoute}/add_component", query_string_hash

          nested_modules = response.required(:nested_modules)
          if nested_modules && !nested_modules.empty?
            clone_args = {
              :base_module      => response.required(:base_module),
              :nested_modules   => nested_modules,
              :service_instance => service_instance,
              :remove_existing  => true,
              :repo_dir         => service_instance_dir
            }
            ClientModuleDir::ServiceInstance.clone_nested_modules(clone_args)
          end

          repo_info_args = Args.new(
            :service_instance     => service_instance,
            :commit_message       => "Updating changes to service instance '#{service_instance}'",
            :branch               => response.required(:base_module, :branch, :name),
            :repo_url             => response.required(:base_module, :repo, :url),
            :service_instance_dir => service_instance_dir
          )
          ClientModuleDir::GitRepo.pull_from_service_repo(repo_info_args)

          OsUtil.print_info("Component '#{component_ref}' has been successfully added to service instance '#{service_instance}'")
        end
      end
    end
  end
end
