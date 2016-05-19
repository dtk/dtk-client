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
        Error.top_level_trap_error(Logger.instance) do
          Configurator.check_git
          Configurator.create_missing_client_dirs
          
          # checks if config exists and if not prompts user with questions to create a config
          config_existed = Configurator.check_config_exists
          
          raise_error_if_invalid_connection
          
          # check if .add_direct_access file exists, if not then add direct access and create .add_direct_access file
          DTKNAccess.resolve_direct_access(config_existed)
          
          if response_obj = Context.determine_context.run_and_return_response_object(argv)
            # render_response will raise Error in case of error response
            render_response(response_obj)
          end
        end
      end
      
      private
      
      def self.raise_error_if_invalid_connection
        connection = Session.get_connection
        raise Error::InvalidConnection.new(connection) if connection.connection_error?
      end

      def self.render_response(response_obj)
        # this will raise error if found
        Response::ErrorHandler.check(response_obj)
        if print = response_obj.render_data
          print = [print] unless print.kind_of?(Array)
          print.each do |el|
            if el.kind_of?(String)
              el.each_line{|l| STDOUT << l}
            else
              PP.pp(el, STDOUT)
            end
          end
        end
      end
    end
  end
end
