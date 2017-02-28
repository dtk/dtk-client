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
require 'singleton'

module DTK::Client
  ##
  # Session Singleton we will use to hold connection instance, just a singleton wrapper.
  # During shell input it will be needed only once, so singleton was obvious solution.
  #
  class Session
    include Singleton

    attr_accessor :conn
    
    def initialize
      @conn = Conn.new
    end
    
    # opts can have keys
    #  :reset
    def self.get_connection(opts = {})
      instance.conn = Conn.new if opts[:reset]
      instance.conn
    end
    
    def self.connection_username
      instance.conn.get_username
    end
    
    def self.re_initialize
      instance.conn = nil
      instance.conn = Conn.new
      instance.conn.cookies
    end
    
    def self.logout
      # from this point @conn is not valid, since there are no cookies set
      instance.conn.logout
    end
    
    def self.rest_post(route, post_body = {})
      instance.conn.post(route, post_body)
    end

    def self.rest_get(route, opts = {})
      instance.conn.get(route, opts)
    end

  end
end
