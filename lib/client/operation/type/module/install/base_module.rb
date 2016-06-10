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
      BaseRoute = "modules"

      # DTK-2554: Aldin: We will subtsantially modify BaseModule.install; right now all original code is still here
      #  The key change will be:  rather than doing seperate
      #  interactions with server to import the service module and component module (if it exists)
      #  we will instead do this in an interaction with server that has teh server create an empty repo
      #  where this repo wil either be a component repo or a new kind of repo that handles both component and service
      #  info and then pushes all the content under the project repo.
      #  Open question if send the yaml parsed dsl hash object or have server from info it pulls pasrses it
      def self.install(base_module_ref, components, file_obj)
        import_component_modules(base_module_ref, components) if components
        post_body = {
          :module_name => base_module_ref.module_name,
          :namespace   => base_module_ref.namespace,
          :content     => file_obj.yaml_parse_hash
        }

        if version = base_module_ref.version
          post_body.merge!(:version => version)
        end

        rest_post "#{BaseRoute}/install_service_module", PostBody.new(post_body)
      end
      
      private

      def self.import_component_modules(base_module_ref, components)
        namespace = base_module_ref.namespace
        components.each do |cmp_name, content|
          import_component_module(namespace, cmp_name, content)
        end
      end

      def self.import_component_module(namespace, module_name, content)
        post_body = {
          :module_name => component_module.module_name,
          :namespace   => component_module.namespace
        }
        if version = component_module.version
          post_body.merge!(:version => version)
        end
        response = rest_post "#{BaseRoute}/get_module_dependencies", PostBody.new(post_body)

        service_module_id, repo_info = response.data(:service_module_id, :repo_info)
        repo_url, repo_id, module_id, branch, new_module_name = [:repo_url,:repo_id,:module_id,:workspace_branch,:full_module_name].map { |k| repo_info[k.to_s] }
        service_directory = OsUtil.current_dir
        # DTK-2554: Aldin: Assuming you have not got to this; we wil do away with all  Helper(:git_repo) calls and instead use 
        # operations we add to lib/client/operation/type/module_dir/git_repo.rb
        response = Helper(:git_repo).rename_and_initialize_clone_and_push(:service_module, local_module_name, new_module_name, branch, repo_url, service_directory)
      end
    end
  end
end


