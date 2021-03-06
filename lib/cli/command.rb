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
    module Command
      require_relative('command/mixin')
      require_relative('command/token')
      require_relative('command/subcommand')
      require_relative('command/options')
      # above must be included before below
      ALL_COMMANDS = [:service, :module, :account]
      ALL_COMMANDS.each { |command_name| require_relative("command/#{command_name}") }
      
      def self.command_module(command_name)
        const_get command_name.to_s.capitalize
      end
      
      def self.all_command_names
        ALL_COMMANDS
      end
      
      def self.all_command_modules
        all_command_names.map  { |command| command_module(command) }
      end
      
      module All
        Command.all_command_modules.each  { |command_module| include command_module }
      end
    end
  end
end
