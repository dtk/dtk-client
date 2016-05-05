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
    module Service
      include Command::Mixin

#      ALL_SUBCOMMANDS = ['deploy', 'deploy-target']
      ALL_SUBCOMMANDS = ['deploy']
      command_def :desc => 'Subcommands for interacting with DTK services'

      subcommand_def 'deploy' do |c|
        c.arg 'ASSEMBLY-NAME'
        unless context_attributes[:module_name]
          c.arg 'NAMESPACE/MODULE-NAME', :optional
        end
        c.desc 'Deplay a new service instance from the selected assembly'
        c.command :deploy  do |deploy|
          deploy.flag [:i], :arg_name =>'INSTANCE-NAME', :desc => 'If specified, name to call new service instance' 
          deploy.flag [:t], :arg_name => 'PARENT-SERVICE-INSTANCE', :desc => 'Parent Service instance into which the new assembly is deployed' 
          deploy.flag [:v], :arg_name => 'VERSION', :desc => 'Version'
          deploy.switch ['auto-complete'], :default_value => true, :desc => 'If true, components with dependencies are automatically linked'
          deploy.switch [:s, 'stream-results'], :default_value => true, :desc => 'If true, results are streamed as tasks progresses and completes or user enters ^C'
          deploy.action do |global_options, options, args|
            pp [self.class, options, args, context_attributes: context_attributes]
            pp [self.class, options, args]
            puts 'dtk service deploy'
          end
        end
      end
    end
  end
end
