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
        return_code = Error.top_level_trap_error do
          ret = 0
          Configurator.check_git
          Configurator.create_missing_client_dirs
          
          # checks if config exists and if not prompts user with questions to create a config
          config_existed = Configurator.check_config_exists
          
          raise_error_if_invalid_connection
          
          # check if .add_direct_access file exists, if not then add direct access and create .add_direct_access file
          DTKNAccess.resolve_direct_access(config_existed)

          context =  Context.determine_context
          add_missing_context(argv, context)
          if response_obj = context.run_and_return_response_object(argv)
            # render_response will raise Error in case of error response
            render_response(response_obj)
            # response_obj can have not ok stateto signal to exit with error
            ret = Error::GENERIC_ERROR_RETURN_CODE if response_obj.notok?
          end
          ret
        end
        exit return_code
      end
      
      private

      CONNECTION_RETRIES = 20
      SLEEP_BETWEEN_RETRIES = 1
      def self.raise_error_if_invalid_connection
        connection_retries = connection_retries()
        count = 0
        while count < connection_retries 
          connection = Session.get_connection(count == 0 ? {} : { reset: true })
          return unless connection.connection_error?
          if connection.connection_refused_error_code?
            sleep SLEEP_BETWEEN_RETRIES
            count += 1
          else
            raise Error::InvalidConnection.new(connection)
          end
        end
        raise Error::InvalidConnection.new(connection)
      end

      def self.connection_retries
        ret = 
          if env_val = ENV['DTK_CONNECTION_RETRIES']
            env_val.to_i rescue nil  
          end
        ret || CONNECTION_RETRIES
      end

      def self.render_response(response_obj)
        Response::ErrorHandler.raise_if_error_info(response_obj)
        response_obj.render_data
      end

      def self.add_missing_context(argv, context)
        add_context = true

        if context_type = context.context_type
          allowed_commands = context.allowed_commands_defs
          allowed_commands.each {|cmd| add_context = false if argv.include?(cmd)}
          argv.unshift(context_type) if add_context
        end
      end
    end
  end
end
