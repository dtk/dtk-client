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
      # dtk service component add [-v VERSION -n NAMESPACE] [-p PARENT] [--workflows LIST-OF-WORKFLOWS-to_ADD-IT-TO] COMPONENT-INSTANCE-REF
      subcommand_def 'add-component' do |c|
        c.arg Token::Arg.component_ref
        command_body c, 'add-component', 'Add component to service instance' do |sc|
          sc.flag Token.version
          sc.flag Token.namespace
          sc.flag Token.parent
          sc.action do |_global_options, options, args|
            args = {
              component_ref: args[0],
              version: options[:v],
              namespace: options[:n],
              parent_node: options[:p]
            }
            Operation::Service.add(args)
          end
        end
      end
    end
  end
end; end