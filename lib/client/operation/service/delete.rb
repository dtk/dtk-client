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
    class Delete < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          @service_instance = args.required(:service_instance)
          recursive        = args.required(:recursive)
          force            = args[:force]
          directory_path   = args[:directory_path]

          if path = args[:path]
            delete_service_path(path)
          else
            unless args[:skip_prompt]
              return false unless Console.prompt_yes_no("Are you sure you want to delete the content of service instance '#{@service_instance}' ?", :add_options => true)
            end

            if !force && directory_path
              modified_args = Args.new(
                :dir => directory_path,
                :error_msg => "To allow delete to go through, invoke 'dtk push' to push the changes to server before invoking delete again",
                :command => 'delete'
              )
              ClientModuleDir::ServiceInstance.modified_service_instance_or_nested_modules?(modified_args)
            end

            post_body = PostBody.new(
              :service_instance => @service_instance,
              :recursive? => recursive
            )
            response = rest_post("#{BaseRoute}/delete", post_body)

            OsUtil.print_info("Delete procedure started. For more information use 'dtk task-status'.")
            display_node_info(response.data)
          end
        end
      end

      # TODO: DTK-2938: below need sto be upgraded to be consistent with node as a component
      def self.display_node_info(nodes, message = '')
        if nodes.size > 0
          nodes.each do |node|
            return if  node['instance_id'].nil?
            message += "#{node['display_name']} - #{node['instance_id']}\n"
          end
          OsUtil.print("Nodes that will be deleted: \n" + message)
        end
      end

      def self.delete_service_path(path)
        return false unless Console.prompt_yes_no("Are you sure you want to delete '#{path}' ?", :add_options => true)

        post_body = PostBody.new(
          :service_instance => @service_instance,
          :path => path
        )
        rest_post("#{BaseRoute}/delete_by_path", post_body)
      end

    end
  end
end