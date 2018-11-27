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
    module Service
      subcommand_def 'describe' do |c|
       c.arg Token::Arg.path
        command_body c, 'describe', 'Describe service instance content' do |sc|
          sc.switch Token.show_steps, :desc => 'Show steps that will be executed when action is executed'
          sc.action do |_global_options, options, _args|
            args = {
              service_instance: service_instance_in_options_or_context(options),
              path: _args[0],
              show_steps: options['show-steps']
            }
            Operation::Service.describe(args)
          end
        end
      end
    end
  end
end; end