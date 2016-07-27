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
  module CLI::Command::Term
    class Switch
      Info = Struct.new(:opt, :desc, :default_value)
      
      def self.switch(gli_command, *args)
        new(gli_command).switch(*args)
      end
      
      def initialize(gli_command)
        @gli_command = gli_command
      end
      private :initialize
      
      def switch(*args)
        switch_with_term?(*args) || gli_command_switch(*args) 
      end
      
      private
      
      def gli_command_switch(*args)
        @gli_command.send(:switch, *args)
      end
      
      def switch_with_term?(*args)
        if args[0].kind_of?(Switch::Info)
          term_switch = args[0]
          case args.size
          when 1
            gli_command_switch(term_switch.opt, :default_value => term_switch.default_value, :desc => term_switch.desc)
          when 2
            if args[1].kind_of?(::Array)
              gli_command_switch(args[1], :default_value => term_switch.default_value, :desc => term_switch.desc)
            elsif args[1].kind_of?(::Hash)
              gli_command_switch(term_switch.opt, switch_merge_keys(term_switch, args[1]))
            end
          when 3
            if args[1].kind_of?(::Array) and args[2].kind_of?(::Hash)
              gli_command_switch(args[1], switch_merge_keys(term_switch, args[2]))
            end
          end
        end
      end
      
      def switch_merge_keys(term_switch, switch_hash)
        {
          :default_value => switch_hash[:default_value] || term_switch.default_value,
          :desc => switch_hash[:desc] || term_switch.desc
        }
      end
    end
  end
end
