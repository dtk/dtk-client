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
  class Error < ::NameError
    require_relative('error/subclasses')

    # opts can have keys
    #  :backtrace - if want backtrace of nested error
    def initialize(msg = '', opts = {})
      super(msg)
      @backtrace = opts[:backtrace] 
    end

    NO_BACKTRACE = :no_backtarce

    def backtrace?
     if @backtrace
       @backtrace unless @backtrace == NO_BACKTRACE
     else
       backtrace
     end
    end
    
    def self.raise_error(response)
      raise_if_error?(response, :default_error_if_nil => true)
    end

    def self.raise_if_error?(response, opts = {})
      # check for errors in response
      unless error = response.error_info?(opts)
        return
      end
      
      # if error_internal.first == true
      case error.code
          when :unauthorized
        raise self, "[UNAUTHORIZED] Your session has been suspended, please log in again."
      when :session_timeout
        raise self, "[SESSION TIMEOUT] Your session has been suspended, please log in again."
      when :broken
        raise self, "[BROKEN] Unable to connect to the DTK server at host: #{Config[:server_host]}"
      when :forbidden
        raise self, "[FORBIDDEN] Access not granted, please log in again."
      when :timeout
        raise self, "[TIMEOUT ERROR] Server is taking too long to respond."
      when :connection_refused
        raise self, "[CONNECTION REFUSED] Connection refused by server."
      when :resource_not_found
        raise self, "[RESOURCE NOT FOUND] #{error.msg}"
      when :pg_error
        raise self, "[PG_ERROR] #{error.msg}"
      when :server_error
        # Unless explicit backtrace given we dont want to use as backtace where error detected on client
        raise Server.new(error.msg, :backtrace => NO_BACKTRACE)
      when :client_error
        raise Client.new(error.msg, :backtrace => error.backtrace)
      else
        # if usage error occurred, display message to console and display that same message to log
        raise Usage.new(error.msg)
      end
    end
  end
end
