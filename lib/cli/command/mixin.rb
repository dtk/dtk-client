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
    module Mixin

      module Common
        private
        def mangled_method(command_name)
          "command_defs__#{command_name}".to_sym
        end
      end

      include Common
      
      def add_command(command_name)
        send(mangled_method(command_name))
      end

      private
      
      def self.included(klass)
        klass.extend(Class)
      end

      module Class
        include Common
        def command_def(command_name = nil, &block)
          command_name ||= command_name()
          mangled_method = mangled_method(command_name)
          class_eval { define_method(mangled_method, &block) }
        end

        def command_def(opts = {})
          command_name = command_name()
          mangled_method = mangled_method(command_name)
          subcommands_info = all_subcommands.map do |subcommand_name|
            {
              :name => subcommand_name,
              :mangled_method => mangled_subcommand_method(subcommand_name)
            }
          end
pp [:outside, subcommands_info]
          block = proc do
            if desc = opts[:desc]
              desc desc
            end
            command command_name do |c|
              @c = c
            end
            subcommands_info.each do |subcommand_info|
              send(subcommand_info[:mangled_method], subcommand_info[:name])
            end
          end

          class_eval { define_method(mangled_method, &block) }
        end

        def subcommand_def(subcommand_name, &block)
          mangled_subcommand_method = mangled_subcommand_method(subcommand_name)
          class_eval { define_method(mangled_subcommand_method, &block) }
        end

        private

        def mangled_subcommand_method(subcommand_name)
          "#{mangled_method(command_name)}__#{subcommand_name}".to_sym
        end

        def all_subcommands
          self::ALL_SUBCOMMANDS
        end

        def command_name
          self.to_s.split('::').last.downcase.to_sym
        end
      end

    end
  end
end
