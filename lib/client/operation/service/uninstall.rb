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
    class Uninstall < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          service_instance = args.required(:service_instance)
          recursive        = args.required(:recursive)
          force            = args.required(:force)
          path             = args[:directory_path]
          node             = []
          msg              = "Are you sure you want to uninstall the infrastructure associated with '#{service_instance}' and delete this service instance from the server?"
          
          if !force && path
            modified_args = Args.new(
              :dir => path || @module_ref.client_dir_path,
              :error_msg => "To allow uninstall to go through, invoke 'dtk push' to push the changes to server before invoking uninstall again",
              :command => 'uninstall'
            )
            ClientModuleDir::ServiceInstance.modified_service_instance_or_nested_modules?(modified_args)
          end

          if force
            msg.prepend("Note: this will not terminate aws instances, you will have to do that manually!\n")
          end

          unless args[:skip_prompt]
            return false unless Console.prompt_yes_no(msg, :add_options => true)
          end

          post_body = PostBody.new(
            :service_instance => service_instance,
            :recursive?  => recursive,
            :delete      => true,
            :force       => force
          )
          response = rest_post("#{BaseRoute}/uninstall", post_body)
          path = ClientModuleDir.ret_base_path(:service, service_instance) unless path
          path = path+'/' if path
          ClientModuleDir.rm_f(path) if args[:purge]

          if message = response.data(:message) || "DTK service '#{service_instance}' has been uninstalled successfully."
            Dir.entries(path).each do |f|
              ClientModuleDir.rm_f(path+f) if f.include? '.task_id_'
            end
            ClientModuleDir.create_file_with_content(path+".task_id_#{response.data(:task_id)}", '') if response.data(:task_id)
            OsUtil.print_info(message)
          end
        end
      end


    end
  end
end
