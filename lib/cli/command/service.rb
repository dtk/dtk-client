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
      include Command::Mixin

#      ALL_SUBCOMMANDS = ['deploy', 'deploy-target', 'stage', 'stage-target']
      ALL_SUBCOMMANDS = ['stage']
      command_def :desc => 'Subcommands for creating and interacting with DTK service instances'

      subcommand_def 'stage' do |c|
        c.arg 'ASSEMBLY-NAME'
        unless context_attributes[:module_name]
          c.arg 'NAMESPACE/MODULE-NAME', :optional
        end
        c.desc 'Stage a new service instance from an assembly'
        c.command :stage  do |sc|
          sc.flag [:i], :arg_name =>'INSTANCE-NAME', :desc => 'If specified, new service instance name' 
          sc.flag [:t], :arg_name => 'PARENT-SERVICE-INSTANCE', :desc => 'Parent Service instance providing the context for the staged assembly' 
          sc.flag [:v], :arg_name => 'VERSION', :desc => 'Version'
          sc.switch ['auto-complete'], :default_value => true, :desc => 'If true, components with dependencies are automatically linked'
          sc.switch [:s, 'stream-results'], :default_value => true, :desc => 'If true, results are streamed as tasks progresses and completes or user enters ^C'
          sc.action do |global_options, options, args|
            Operation::Service.stage()
          end
        end
      end
    end
  end
end; end
