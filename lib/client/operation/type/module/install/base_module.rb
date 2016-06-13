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

        # tell server to create a module that wil be used to push the contents of project folder to
        post_body = PostBody.new(
          :module_name => base_module_ref.module_name,
          :namespace   => base_module_ref.namespace,
          :version?    => base_module_ref.version
        )

        response = rest_post("#{BaseRoute}/create_empty_module", post_body)
        pp [:debug, response]

        # # DTK-2554: Aldin: 
        # put in steps that 
        # 1) pushes the content to the newly created module repo
        #   if project folder is a git repo add a remote that points to the newly created module and then
        #   push content; otherwise create a a new git clone in project folder and point it to the newly created module
        #   and push content
        # 2) call rest_post "#{BaseRoute}/update_from_repo (which in past we have called 'update_model_from_clone

        args = {
          :repo_dir => OsUtil.current_dir,
          :repo_url => response.required(:repo_url),
          :branch   => response.required(:branch_name)
        }
        ModuleDir::GitRepo.add_remote_and_push(args)
      end
    end
  end
end


