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
      @cookies = Hash.new
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
    
    def rest_url(route = nil)
      "#{rest_url_base}/rest/#{route}"
    end

    def get(command_class,url)
      ap "GET #{url}" if verbose_mode_on?
      
      check_and_wrap_response(command_class, Proc.new { json_parse_if_needed(get_raw(url)) })
    end
    
    def post(command_class,url,body=nil)
      if verbose_mode_on?
        ap "POST (REST) #{url}"
        ap "params: "
        ap body
      end
      
      check_and_wrap_response(command_class, Proc.new { json_parse_if_needed(post_raw(url,body)) })
    end
    
    def post_file(command_class,url,body=nil)
      if verbose_mode_on?
          ap "POST (FILE) #{url}"
        ap "params: "
        ap body
      end
      
      check_and_wrap_response(command_class, Proc.new { json_parse_if_needed(post_raw(url,body,{:content_type => 'avro/binary'})) })
    end

    # method will repeat request in case session has expired
    def check_and_wrap_response(command_class, rest_method_func)
      response = rest_method_func.call
      
      if ResponseErrorHandler.check_for_session_expiried(response)
        # re-logging user and repeating request
        OsUtil.print("Session expired: re-establishing session & re-trying request ...", :yellow)
        @cookies = Session.re_initialize
        response = rest_method_func.call
      end
      
        response_obj = Response.new(command_class, response)
      
      # queue messages from server to be displayed later
      DTK::Shell::MessageQueue.process_response(response_obj)
      
      response_obj
    end
    
    def connection_error?
      return !@connection_error.nil?
    end
    
    def logout
      response = get_raw rest_url("user/process_logout")
      
      # save cookies - no need to persist them
      # DiskCacher.new.save_cookie(@cookies)

      raise Error, "Failed to logout, and terminate session!" unless response
      @cookies = nil
    end
    
    ##
      # Method will warn user that connection could not be established. User should check configuration
    # to make sure that connection is properly set.
    #
    def print_warning
      creds = get_credentials
      puts   "[WARNING] Unable to connect to server, please check you configuration."
      puts   "========================== Configuration =========================="
      printf "%15s %s\n", "REST endpoint:", rest_url
      printf "%15s %s\n", "Username:", "#{creds[:username]}"
      printf "%15s %s\n", "Password:", "#{creds[:password] ? creds[:password].gsub(/./,'*') : 'No password set'}"
      puts   "==================================================================="
      
      if self.connection_error['errors'].first['errors']
        error_code = self.connection_error['errors'].first['errors'].first['code']
        print " Error code: "
        OsUtil.print(error_code, :red)
      end
    end
    
    private

    def rest_url_base
      @@rest_url_base ||= get_rest_url_base
    end

    def get_rest_url_base
      protocol, port = 
        if "#{Config[:secure_connection]}" == 'true'
          ['http', Config[:server_port].to_s]
        else
          ['https', Config[:secure_connection_server_port].to_s]
        end
      "#{protocol}://#{Config[:server_host]}:{port}"
    end
    
    def verbose_mode_on?
      if @@verbose_mode_on.nil?
        if @@verbose_mode_on ||= !!Config[:verbose_rest_calls]
          require 'ap'
        end
      end
      @@verbose_mode_on
    end

    def login
      creds = get_credentials
      response = post_raw rest_url("user/process_login"),creds
      errors = response['errors']
      
      if response.kind_of?(Common::Response) and not response.ok?
        if (errors && errors.first['code']=="pg_error")
          OsUtil.print(errors.first['message'].gsub!("403 Forbidden", "[PG_ERROR]"), :red)
          exit
        end
        @connection_error = response
      else
        @cookies = response.cookies
      end
    end
    
    def set_credentials(username, password)
      @parsed_credentials = { :username => username, :password => password}
    end
    
    def get_credentials
      @parsed_credentials ||= Configurator.get_credentials
    end

    def default_rest_opts
      @@default_rest_opts ||= get_default_rest_opts
    end

    def get_default_rest_opts
      # In development mode we want bigger timeout allowing us to debbug on server while still
      # keeping connection alive and receivinga response
      timeout = Config[:development_mode] ? 2000 : 150
      {
        :timeout => timeout,
        :open_timeout => 10,
        :error_response_class => Client::Response::Error,
        :verify_ssl => OpenSSL::SSL::VERIFY_PEER,
        :ssl_ca_file => File.expand_path('../lib/config/cacert.pem', File.dirname(__FILE__)),
      }
    end
    
    def get_raw(url)
      RestClientWrapper.get_raw(url, {}, default_rest_opts.merge(:cookies => @cookies))
    end
    def post_raw(url, body, params = {})
      RestClientWrapper.post_raw(url, body, default_rest_opts.merge(:cookies => @cookies).merge(params))
    end
    
    def json_parse_if_needed(item)
      RestClientWrapper.json_parse_if_needed(item)
    end
  end
end

