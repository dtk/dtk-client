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
  class Operation::Service::TaskStatus
    class RefreshMode < self
      DEBUG_SLEEP_TIME = 5 #DTK::Configuration.get(:debug_task_frequency)

      def task_status(opts = {})
        begin
          response = nil
          loop do
            response = rest_call(opts)
            return response unless response.ok?
            
            # TODO: clean this up
            # stop polling when top level task succeeds, fails or timeout
            if response and response.data and response.data.first
              if debug_mode?(response)
                response.print_error_table!(true)
                add_info_if_debug_mode!(response)
                return response
              end

              top_task_failed = response.data.first['status'].eql?('failed')
              is_pending        = (response.data.select {|r|r['status'].nil? }).size > 0
              is_executing      = (response.data.select {|r|r['status'].eql? 'executing'}).size > 0
              is_failed         = (response.data.select {|r|r['status'].eql? 'failed'}).size > 0
              is_cancelled      = response.data.first['status'].eql?('cancelled')

              is_cancelled = true if top_task_failed
              
              unless (is_executing || is_pending) && !is_cancelled
                system('clear')
                # response.print_error_table = true
                # response.render_table(:task_status)
                response.print_error_table!(true)
                return response.set_render_as_table!
              end
            end

            system('clear')
            response.set_render_as_table!
            response.render_data
            
            Console.wait_animation("Watching '#{@object_type}' task status [ #{DEBUG_SLEEP_TIME} seconds refresh ] ", DEBUG_SLEEP_TIME)
          end
          rescue Interrupt => e
          puts ""
          response.skip_render(true) unless response.nil?
          return
        end
      end
    end
  end
end

