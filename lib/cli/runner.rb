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
  module CLI
    # Top-level entry class for dtk CLI executable
    class Runner
      require_relative('runner/dtkn_access')
      
      def self.run(argv)
        begin 
          Configurator.check_git
          Configurator.create_missing_client_dirs
          
          # checks if config exists and if not prompts user with questions to create a config
          config_existed = Configurator.check_config_exists
          
          raise_error_if_invalid_connection
        
          # check if .add_direct_access file exists, if not then add direct access and create .add_direct_access file
          DTKNAccess.resolve_direct_access(config_existed)
          
          response_obj = Context.determine_context.run_and_return_response_object(argv)
          # render_response will raise DTK::Client::Error in case of error response
          render_response(response_obj)
        rescue Error::InvalidConnection => e
          e.print_warning
          puts "\nDTK will now exit. Please set up your connection properly and try again."
        rescue Error => e
          # this are expected application errors
          Logger.instance.error_pp(e.message, e.backtrace)
        rescue Exception => e
          Logger.instance.fatal_pp("[#{Error::Client.label}] DTK has encountered an error #{e.class}: #{e.message}", e.backtrace)
        end
      end
      
      private

      def self.raise_error_if_invalid_connection
        connection = Session.get_connection
        raise Error::InvalidConnection.new(connection) if connection.connection_error?
      end
    end
  end
end
