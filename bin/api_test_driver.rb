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

module DTK
  class ApiTestDriver
    include DTK::Client
    
    attr_reader :service_name
    def initialize(service_name)
      @service_name = service_name
    end
    
    def service_exists?
      # Since do not havce exists api detecting if service exists already by doing services/list
      response = nil
      wrap_response(:list, dont_display_response: true) do
        response = Session.rest_get('services/list')      
      end
      !! response.data.find { |service_instance| service_instance['display_name'] == service_name }
    end
    
    def stage
      wrap_response(:stage) do
        post_body = PostBody.new(
          :namespace       => 'lab-manager',
          :module_name     => 'workshop',
          :version?        => 'master',
          :assembly_name?  => 'converge_test',
          :service_name    => service_name
        )
        Session.rest_post('modules/stage', post_body)
      end
    end

    def uninstall_service
      wrap_response(:uninstall_service) do
        post_body = PostBody.new(
          :service_instance => service_name,
          :delete           => true
        )
        Session.rest_post("services/uninstall", post_body)
      end
    end

    def set_service_attribute(attribute_path, attribute_value)
      wrap_response(:set_service_attribute, dont_display_response: true) do
        query_string_hash = QueryStringHash.new(
          :pattern => attribute_path,
          :value?  => attribute_value
        )
        Session.rest_post("services/#{service_name}/set_attribute", query_string_hash)
      end
    end

    def fail_on_violations
      response = nil
      wrap_response(:fail_on_violations) do
        response = Session.rest_get("services/#{service_name}/violations")
      end
      
      exit_because_error if response.data and response.data.size > 0
    end
    
    def converge
      wrap_response(:converge) do
        post_body = PostBody.new(
          :service_instance => service_name
        )
        Session.rest_post("services/#{service_name}/converge", post_body)
      end
    end

    EXECUTING_STATES = ['executing', nil]
    def is_executing?(state)
      EXECUTING_STATES.include?(state)
    end

    POLL_INTERVAL = 10
    def wait_until_complete
      try_again = true
      while try_again
        #        state = task_status_summary(dont_display_response: true)
        state = task_status_summary(dont_display_response: true)
        if is_executing?(state)
          puts "Queried task, but still executing\n"
          sleep POLL_INTERVAL
        else
          try_again = false
        end
      end
      state
    end

    # opts can have keys:
    #   :dont_display_response
    def task_status_summary(opts = {})
      response = nil
      wrap_response(:task_status, dont_display_response: opts[:dont_display_response]) do 
        response = Session.rest_get("services/#{service_name}/task_status")
      end
      summary_row = response.data.find do |task_status_row|
        # this has top and nested row; below is check for summary row'
        task_status_row['index'].nil?
      end
      summary_row['status']
    end

    private

    # opts can have keys:
    #   :dont_display_response
    def wrap_response(operation, opts = {}, &body)
      response = yield
      print(operation, response) unless opts[:dont_display_response]
      exit_because_error unless response.ok?
      response
    end

    def exit_because_error
      pp 'exiting on error'
      exit 1
    end

    def print(operation, response)
      pp ["#{operation}_response", response]
    end

  end
end
