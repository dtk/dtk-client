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
  # Abstract class that holds classes and methods for xecuting commands by
  # make calls to server and performing client side operations
  class Operation

    require_relative('operation/module_service_common')

    TYPES = [:account, :module, :service, :client_module_dir]
    TYPES.each { |op_type| require_relative("operation/#{op_type}") }
      
    private
    
    # delegate rest calls to Session
    def self.rest_post(route, post_body = {})
      raise_error_if_notok_response do
        Session.rest_post(route, post_body)
      end
    end
    def rest_post(route, post_body = {})
      self.class.rest_post(route, post_body)
    end

    def self.rest_get(route, query_string_hash = {})
      raise_error_if_notok_response do
        Session.rest_get(route, query_string_hash)
      end
    end
    def rest_get(route, query_string_hash = {})
      self.class.rest_get(route, query_string_hash)
    end

    def self.wrap_operation(args = Args.new, &block)
      Response.wrap_as_response do
        block.call(Args.convert(args))
      end
    end

    # This is used so can fail on not ok rest responses without needing to do explicit
    # response.ok? checks in many places
    def self.raise_error_if_notok_response(&block)
      response = block.call
      if response.ok?
        response
      else
        raise Error::ServerNotOkResponse.new(response)
      end
    end
  end
end

