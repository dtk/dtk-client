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

          # parse params and return format { 'p_name1' => 'p_value1' , 'p_name2' => 'p_value2' }
          task_params = parse_params?(action_params)||{}

          # match if sent node/component
          if task_action_match = action.match(/(^[\w\-\:]*)\/(.*)/)
            node, action = $1, $2
            task_params.merge!("node" => node)
          end
          
          error_msg = "To allow #{args[:command]} to go through, invoke 'dtk push' to push the changes to server before invoking #{args[:command]} again"
          GitRepo.modified_with_diff?(directory_path, { :error_msg => error_msg, :command => 'exec'})
        
          post_body = PostBody.new(
            :task_params? => task_params
          )
          encoded_action =  URI.encode_www_form_component("#{action}")
          require 'debugger'
          Debugger.start
          debugger
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

          if response.data(:violations)
            OsUtil.print_error("Cannot execute an action or workflow if there are violations:")
            return response.set_render_as_table!
          end

          response
        end
      end

      private

      def self.parse_params?(params_string)
        if params_string
          params_string.split(',').inject(Hash.new) do |h,av|
            av_split = av.split('=')
            unless av_split.size == 2
              raise Error::Usage, "The parameter string (#{params_string}) is ill-formed"
            end
            h.merge(av_split[0] => av_split[1])
          end
        end
      end
    end
  end
end
