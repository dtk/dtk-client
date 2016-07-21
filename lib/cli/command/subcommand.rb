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
module DTK::Client; module CLI
  module Command
    class Subcommand
      def initialize(gli_command)
        @gli_command = gli_command
      end

      def method_missing(method, *args, &body)
        @gli_command.send(method, *args, &body)
      end

      def respond_to?(method)
        @gli_command.send(:respond_to?, method)
      end

      def action(*args, &body)
        @gli_command.send(:action, *args) do |global_options, options, args|
          body.call(global_options, Options.new(options), args)
        end
      end

      def flag(*args)
        flag_with_term?(*args) || gli_command_flag(*args) 
      end

      private

      def gli_command_flag(*args)
        @gli_command.send(:flag, *args)
      end

      def flag_with_term?(*args)
        if args[0].kind_of?(Term::Flag::Info)
          term_flag = args[0]
          case args.size
          when 1
            gli_command_flag(term_flag.opt, :arg_name => term_flag.arg_name, :desc => term_flag.desc)
          when 2
            if args[1].kind_of?(::Array)
              gli_command_flag(args[1], :arg_name => term_flag.arg_name, :desc => term_flag.desc)
            elsif args[1].kind_of?(::Hash)
              gli_command_flag(term_flag.opt, flag_merge_keys(term_flag, args[1]))
            end
          when 3
            if args[1].kind_of?(::Array) and args[2].kind_of?(::Hash)
              gli_command_flag(args[1], flag_merge_keys(term_flag, args[2]))
            end
          end
        end
      end

      def flag_merge_keys(term_flag, flag_hash)
        {
          :arg_name => flag_hash[:arg_name] || term_flag.arg_name,
          :desc => flag_hash[:desc] || term_flag.desc
        }
      end

    end
  end
end; end

