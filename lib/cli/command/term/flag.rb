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
  module Command::Term
    module Flag
      Info = Struct.new(:opt, :arg_name, :desc)
      
      def self.version
        Info.new(:v, 'VERSION', 'Version')
      end
      
      def self.service_instance
        Info.new(:s, 'SERVICE-INSTANCE', 'Service instance name')
      end
      
      def self.target_service_instance
        Info.new(:t, 'TARGET-SERVICE-INTANCE', 'Target service instance name')
      end
      
      def self.namespace_module_name
        Info.new(:m, 'NAMESPACE/MODULE-NAME', 'Module name with namespace')
      end
      
      #### 
      # general methods
      def self.opt?(flag_name)
        send(flag_name).opt if respond_to?(flag_name) 
      end
      
      def self.option_ref(flag_name)
        flag_info = send(flag_name)
        "-#{flag_info.opt} #{flag_info.arg_name}"
      end
      
      class Helper
        def self.flag(gli_command, *args)
          new(gli_command).flag(*args)
        end
        
        def initialize(gli_command)
          @gli_command = gli_command
        end
        private :initialize

        def flag(*args)
          flag_with_term?(*args) || gli_command_flag(*args) 
        end

        private
        
        def gli_command_flag(*args)
          @gli_command.send(:flag, *args)
        end
        
        def flag_with_term?(*args)
          if args[0].kind_of?(Flag::Info)
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
  end
end; end
