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
  class Conn
    def initialize
      @cookies          = {}
      @connection_error = nil
      login
    end
    
    attr_reader :connection_error, :cookies
    
    def self.get_timeout
      default_rest_opts[:timeout]
    end
    
    def self.set_timeout(timeout_sec)
      default_rest_opts[:timeout] = timeout_sec
    end
    
    def get_username
      get_credentials[:username]
    end
    
    def get(route, query_string_hash = {})
      url = rest_url(route)
      ap "GET #{url}" if verbose_mode_on?
      
      check_and_wrap_response { json_parse_if_needed(get_raw(url, query_string_hash)) }
    end
    
    def post(route, post_body = {})
      url = rest_url(route)
      if verbose_mode_on?
        ap "POST (REST) #{url}"
        ap "params: "
        ap post_body
      end
      
      check_and_wrap_response { json_parse_if_needed(post_raw(url, post_body)) }
    end
    
    def post_file(route, post_body = {})
      url = rest_url(route)
      if verbose_mode_on?
          ap "POST (FILE) #{url}"
        ap "params: "
        ap post_body
      end
      
      check_and_wrap_response { json_parse_if_needed(post_raw(url,post_body,{:content_type => 'avro/binary'})) }
    end

    ##
    # Method will warn user that connection could not be established. User should check configuration
    # to make sure that connection is properly set.
    #
    def print_warning
      creds = get_credentials
      puts   "[ERROR] Unable to connect to server, please check you configuration."
      puts   "========================== Configuration =========================="
      printf "%15s %s\n", "REST endpoint:", rest_url
      printf "%15s %s\n", "Username:", "#{creds[:username]}"
      printf "%15s %s\n", "Password:", "#{creds[:password] ? creds[:password].gsub(/./,'*') : 'No password set'}"
      puts   "==================================================================="
      
      if error_code =  error_code?
        OsUtil.print_error("Error code: #{error_code}")
      end
    end

    def connection_error?
      !connection_error.nil?
    end

    def connection_refused_error_code?
      error_code? == 'connection_refused' or
        (original_exception? and original_exception?.kind_of?(::Errno::EPIPE))
    end
    
    private

    def error_code?
      connection_error['errors'].first['code'] rescue nil
    end

    def original_exception?
      connection_error['errors'].first['original_exception'] rescue nil
    end

    REST_VERSION = 'v1'
    REST_PREFIX = "rest/api/#{REST_VERSION}"
    # REST_PREFIX = "rest"

    def rest_url(route = nil)
      "#{rest_url_base}/#{REST_PREFIX}/#{route}"
    end

    def rest_url_base
      @@rest_url_base ||= get_rest_url_base
    end

    def get_rest_url_base
      protocol, port = 
        if "#{Config[:secure_connection]}" == 'true'
          ['https', Config[:secure_connection_server_port].to_s]
        else
          ['http', Config[:server_port].to_s]
        end
      "#{protocol}://#{Config[:server_host]}:#{port}"
    end
    
    # method will repeat request in case session has expired
    def check_and_wrap_response(&rest_method_func)
      response = rest_method_func.call
      
      if Response::ErrorHandler.check_for_session_expiried(response)
        # re-logging user and repeating request
        OsUtil.print_warning("Session expired: re-establishing session & re-trying request ...")
        @cookies = Session.re_initialize
        response = rest_method_func.call
      end
      
      response_obj = Response.new(response)
      
      # queue messages from server to be displayed later
      #TODO: DTK-2554: put in processing of messages Shell::MessageQueue.process_response(response_obj)
      response_obj
    end

    def verbose_mode_on?
      if @verbose_mode_on.nil?
        if @verbose_mode_on ||= !!Config[:verbose_rest_calls]
          require 'ap'
        end
      end
      @verbose_mode_on
    end

    def login
      response = post_raw rest_url('auth/login'), get_credentials
      if response.kind_of?(::DTK::Common::Response) and ! response.ok?
        @connection_error = response
      else
        @cookies = response.cookies
      end
    end

    def logout
      response = get_raw rest_url('auth/logout')
      # TODO: see if response can be nil
      raise Error, "Failed to logout, and terminate session!" unless response
      @cookies = nil
    end

    def set_credentials(username, password)
      @parsed_credentials = { :username => username, :password => password}
    end
    
    def get_credentials
      @parsed_credentials ||= Configurator.get_credentials
    end

    def default_rest_opts
      @default_rest_opts ||= get_default_rest_opts
    end

    def get_default_rest_opts
      # In development mode we want bigger timeout allowing us to debbug on server while still
      # keeping connection alive and receivinga response
      timeout = Config[:development_mode] ? 2000 : 150
      {
        :timeout => timeout,
        :open_timeout => 10,
        :verify_ssl => OpenSSL::SSL::VERIFY_PEER,
        :ssl_ca_file => File.expand_path('../client/config/cacert.pem', File.dirname(__FILE__)),
      }
    end
    
    def get_raw(url, query_string_hash = {})
      Response::RestClientWrapper.get_raw(url, query_string_hash, default_rest_opts.merge(:cookies => @cookies))
    end

    def post_raw(url, post_body, params = {})
      Response::RestClientWrapper.post_raw(url, post_body, default_rest_opts.merge(:cookies => @cookies).merge(params))
    end
    
    def json_parse_if_needed(item)
      Response::RestClientWrapper.json_parse_if_needed(item)
    end
  end
end

