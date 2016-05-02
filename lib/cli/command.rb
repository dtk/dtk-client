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
module DTK::CLI
  module Command
    ALL_COMMANDS = [:service, :module]

    module Mixin
      def add_command(command)
        send(mangled_method(command))
      end

      module Common
        def mangled_method(command)
          "command_defs__#{command}".to_sym
        end
      end
      include Common

      module Class
        include Common
        def command_def(command, &block)
          mangled_method = mangled_method(command)
          class_eval { "def #{mangled_method}; block.call; end" }
        end
      end

      private

      def self.included(klass)
        klass.extend(Class)
      end

    end

    ALL_COMMANDS.each { |context| require_relative("command/#{context}") }


  end
end
