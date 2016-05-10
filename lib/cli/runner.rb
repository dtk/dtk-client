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
        Configurator.check_git
        Configurator.create_missing_client_dirs
        
        # checks if config exists and if not prompts user with questions to create a config
        config_existed = Configurator.check_config_exists
        
        exit 1 unless valid_connection?
        
        # check if .add_direct_access file exists, if not then add direct access and create .add_direct_access file
        DTKNAccess.resolve_direct_access(config_existed)
        
        command_context = Context.determine_context
        command_context.run(argv)
      end
      
      private
      
      def self.valid_connection?
        connection = Session.get_connection
        if connection.connection_error?
          connection.print_warning
          puts "\nDTK will now exit. Please set up your connection properly and try again."
          false
        else
          true
        end
      end
    end
  end
end
