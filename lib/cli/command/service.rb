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

      ALL_SUBCOMMANDS = ['deploy', 'deploy-target']
      command_def :desc => 'Subcommands for interacting with DTK services'

      subcommand_def 'deploy' do |c|
        c.arg 'ASSEMBLY-NAME'
        unless context_attributes[:module_name]
          c.arg 'NAMESPACE/MODULE-NAME', :optional
        end
        c.desc 'Deploy a new service instance from the selected assembly'
        c.command :deploy  do |sc|
          sc.flag [:i], :arg_name =>'INSTANCE-NAME', :desc => 'If specified, name to call new service instance' 
          sc.flag [:t], :arg_name => 'PARENT-SERVICE-INSTANCE', :desc => 'Parent Service instance into which the new assembly is deployed' 
          sc.flag [:v], :arg_name => 'VERSION', :desc => 'Version'
          sc.switch ['auto-complete'], :default_value => true, :desc => 'If true, components with dependencies are automatically linked'
          sc.switch [:s, 'stream-results'], :default_value => true, :desc => 'If true, results are streamed as tasks progresses and completes or user enters ^C'
          sc.action do |global_options, options, args|
            pp [self.class, options, args, context_attributes: context_attributes]
            pp [self.class, options, args]
            puts 'dtk service deploy'
          end
        end
      end

      subcommand_def 'deploy-target' do |c|
        c.arg 'ASSEMBLY-NAME'
        unless context_attributes[:module_name]
          c.arg 'NAMESPACE/MODULE-NAME', :optional
        end
        c.desc 'Deploy a top level service instance that will serve as a target'
        c.command 'deploy-target'  do |sc|
          sc.flag [:i], :arg_name =>'INSTANCE-NAME', :desc => 'If specified, name to call new service instance' 
          sc.flag [:v], :arg_name => 'VERSION', :desc => 'Version'
          sc.switch ['auto-complete'], :default_value => true, :desc => 'If true, components with dependencies are automatically linked'
          sc.switch [:s, 'stream-results'], :default_value => true, :desc => 'If true, results are streamed as tasks progresses and completes or user enters ^C'
          sc.action do |global_options, options, args|
            pp [self.class, options, args, context_attributes: context_attributes]
            pp [self.class, options, args]
            puts 'dtk service deploy-target'
          end
        end
      end

    end
  end
end; end
