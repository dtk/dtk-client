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
  class CLI::Command::Token
    module ClassMixin
      def method_missing(method, *_args, &_body)
        TOKENS[method] || super
      end

      def respond_to?(method)
        TOKENS.include?(method) or super
      end
      
      def opt?(canonical_name)
        if token = token(canonical_name)
          token.key
        end
      end
      
      def option_ref(canonical_name)
        if token = token(canonical_name)
          token.ref
        else
          ''
        end
      end

      def ret(gli_command, *args)
        ret_when_token_obj?(gli_command, *args) || apply_gli_command(gli_command, *args)
      end
      
      private

      def apply_gli_command(gli_command, *args)
        gli_command.send(token_type, *args)
      end
        

      def token(canonical_name)
        TOKENS[canonical_name]
      end

      def ret_when_token_obj?(gli_command, *args)
        if args[0].kind_of?(self)
          token = args[0]
          case args.size
          when 1
            apply_gli_command(gli_command, token.key, token)
          when 2
            if args[1].kind_of?(::Array)
              apply_gli_command(gli_command, args[1], token) 
            elsif args[1].kind_of?(::Hash)
              apply_gli_command(gli_command, token.key, token.add_overrides(args[1]))
            end
          when 3
            if args[1].kind_of?(::Array) and args[2].kind_of?(::Hash)
              apply_gli_command(gli_command, args[1], token.add_overrides(args[2]))
            end
          end
        end
      end
        
    end
  end
end
