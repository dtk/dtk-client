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
require 'gli'
module DTK::Client; module CLI
  class Processor
    module Plugin
      class Gli
        include ::GLI::App

        def initialize
          @response_obj = nil
        end
        
        def run_and_return_response_object(argv)
          run(argv)
          @response_obj
        end
        
        # add_command_hooks! works in conjunction with run
        def add_command_hooks!
          around do |_global_options, _command, _options, _arguments, code|
            # It is expected that last line in code block returns response
            @response_obj = code.call
          end

          on_error do |err|
            if err.kind_of?(::GLI::BadCommandLine) or err.kind_of?(::GLI::UnknownCommand)
              true # so gli mechanism processes it
            elsif err.kind_of?(::DTK::Base::Error)
              raise err
            else
              raise Error::Client.new(err.message, :backtrace => err.backtrace)
            end
          end
        end

        def add_command_defaults!
          program_desc 'DTK CLI tool'
          version VERSION
          subcommand_option_handling :normal
          arguments :strict
        end
      end
    end
  end
end; end
