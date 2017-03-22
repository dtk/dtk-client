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
      wrap_response(:list) do
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
    
    private
    
    def wrap_response(operation, &body)
      response = yield
      print(operation, response)
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
