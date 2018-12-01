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
    class Exec < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          service_instance = args.required(:service_instance)
          action           = args.required(:action)
          action_params    = args[:action_params]
          directory_path   = args[:directory_path]
          breakpoint       = args[:breakpoint]
          attempts         = args[:attempts] || ""
          sleep            = args[:sleep] || ""    

          task_params = {}
          process_action_params(action_params, task_params) unless action_params.eql? nil

          # this is temporary fix to handle new node as component format ec2::node[node_name]/action
          # will transform ec2::node[node_name]/action to node_name/action
          action_node, action_name = (action||"").split('/')
          if action_node && action_name
            if action_node_match = action_node.match(/^ec2::node\[(.*)\]/) || action_node.match(/^ec2::node_group\[(.*)\]/)
              matched_node = $1
              action = "#{matched_node}/#{action_name}"
            end
          end

          # match if sent node/component
          if task_action_match = action.match(/(^[\w\-\:]*)\/(.*)/)
            node, action = $1, $2
            task_params.merge!("node" => node)
          end

          modified_args = Args.new(
            :dir => directory_path,
            :error_msg => "To allow #{args[:command]} to go through, invoke 'dtk push' to push the changes to server before invoking #{args[:command]} again",
            :command => 'exec'
          )
          ClientModuleDir::ServiceInstance.modified_service_instance_or_nested_modules?(modified_args)
        
          post_body = PostBody.new(
            :task_params? => task_params
          )
          post_body.merge!(:breakpoint => breakpoint) if breakpoint
          post_body.merge!(:attempts => attempts, :sleep => sleep) if attempts || sleep
          encoded_action =  URI.encode_www_form_component("#{action}")
          response = rest_post("#{BaseRoute}/#{service_instance}/#{encoded_action}", post_body)

          if confirmation_message = response.data(:confirmation_message)
            unless Console.prompt_yes_no("Service instance has been stopped, do you want to start it?", :add_options => true)
              return Response::Ok.new(:empty_workflow => true) 
            end

            response = rest_post("#{BaseRoute}/#{service_instance}/#{encoded_action}", post_body.merge!(:start_assembly => true, :skip_violations => true))
          end

          if response.data(:empty_workflow)
            OsUtil.print_warning("There are no steps in the workflow to execute")
            return Response::Ok.new('empty_workflow' => true) 
          end

          response
        end
      end

      private

      def self.process_action_params(action_params, params)
        if match = action_params.match(/([^=]+)=(.+)/)
          extracted_value, new_params = extract_action_value(match[2])
          params.merge!(match[1] => extracted_value)
          process_action_params(new_params, params) unless new_params.empty?
        end
      end

      def self.extract_action_value(ac_params)
        if ac_params.start_with?('[')
          match_and_return(ac_params, :array)
        elsif ac_params.start_with?('{')
          match_and_return(ac_params, :hash)
        else
          if match = ac_params.match(/([^,]+),(.*)/)
            return [match[1], match[2]]
          else
            return [ac_params, ""]
          end
        end
      end

      def self.match_and_return(ac_params, type)
        match = ac_params.match(RegexTypes[type])
        return [match[1], prettify(match[2])]
      end

      RegexTypes = {
        array: Regexp.new(/([^\]]+\])(.*)/),
        hash: Regexp.new(/([^\}]+\})(.*)/)
      }

      def self.prettify(remaining)
        remaining.sub!(",", "") unless remaining.empty?
        remaining
      end
    end
  end
end
