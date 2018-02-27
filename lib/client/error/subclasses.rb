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
  class Error
    class Usage < self
      def initialize(error_msg, _opts = {})
        msg_to_pass_to_super = "[ERROR] #{error_msg}"
        super(msg_to_pass_to_super, :backtrace => NO_BACKTRACE)
      end
    end

    # Used for trapping not ok rest responses
    class ServerNotOkResponse < self
      attr_reader :response
      def initialize(response)
        @response = response
      end
    end

    class InternalError < self
      # opts can have keys
      #  :backtrace
      #  :where
      def initialize(error_msg, opts = {})
        msg_to_pass_to_super = "[#{label(opts[:where])}] #{error_msg}"
        super(msg_to_pass_to_super, opts)
      end
      def self.label(where = nil)
        prefix = (where ? "#{where.to_s.upcase} " : '')
        "#{prefix}#{InternalErrorLabel}"
      end
      InternalErrorLabel = 'INTERNAL ERROR'
      
      private
      def label(where=nil)
        self.class.label(where)
      end
    end
    
    class Client < InternalError
      # opts can have keys
      #  :backtrace
      def initialize(error_msg, opts = {})
        super(error_msg, opts.merge(:where => :client))
      end
      def self.label(*_args)
        super(:client)
      end
    end
    
    class Server < InternalError
      # opts can have keys
      #  :backtrace
      def initialize(error_msg, opts = {})
        if backtrace = opts[:backtrace] 
        # if backrace is empty then dont pass on
          backtrace = nil if backtrace.empty?
        end
        super(error_msg, :where => :server, :backtrace => backtrace)
      end
      def self.label(*args)
        super(:server)
      end
    end

    class InvalidConnection < self
      # TODO: DTK-2554: leveraged connection#print_warning
      # might instead use 'msg_to_pass_to_super'
      def initialize(bad_connection)
        super()
        @bad_connection = bad_connection
      end
      def print_warning
        @bad_connection.print_warning if @bad_connection
      end
    end
    
    class NoMethodForConcreteClass < self
      def initialize(klass)
        method_string = caller[1]
        method_ref =
          if method_string =~ /`(.+)'$/
            method = $1
            " '#{method}'"
          end
        super("No method#{method_ref} for concrete class #{klass}")
      end
    end

    class MissingDslFile < self
      def initialize(error_msg, _opts = {})
        msg_to_pass_to_super = "[ERROR] #{error_msg}"
        super(msg_to_pass_to_super, :backtrace => NO_BACKTRACE)
      end
    end

    class DtkNetwork < self
      # opts can have keys
      #  :backtrace
      def initialize(error_msg, opts = {})
        msg_to_pass_to_super = "[DTK NETWORK ERROR] #{error_msg}"
        super(msg_to_pass_to_super, opts.merge(:where => :dtk_network))
      end
      def self.label(*_args)
        super(:dtk_network)
      end
    end
  end
end
