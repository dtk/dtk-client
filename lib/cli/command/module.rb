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
    module Module 
      include Command::Mixin

      ALL_SUBCOMMANDS = ['install', 'push', 'list-assemblies', 'delete']
      command_def :desc => 'Subcommands for interacting with DTK modules'

      subcommand_def 'install' do |c|
        unless context_attributes[:module_name]
        # TODO: put in later  c.arg 'NAMESPACE/MODULE-NAME', :optional
        end
        command_body c, :install, 'Install DTK module' do |sc|
          sc.action do |_global_options, _options, _args|
            Operation::Module.install(:module_ref => context_attributes[:module_ref], :base_dsl_file_obj => @base_dsl_file_obj)
          end
        end
      end

      subcommand_def 'push' do |c|
        unless context_attributes[:module_name]
        # TODO: put in later  c.arg 'NAMESPACE/MODULE-NAME', :optional
        end
          command_body c, :push, 'Push DTK module' do |sc|
          sc.action do |_global_options, _options, _args|
            Operation::Module.push(:module_ref => context_attributes[:module_ref], :base_dsl_file_obj => @base_dsl_file_obj)
          end
        end
      end

      subcommand_def 'list-assemblies' do |c|
        command_body c, 'list-assemblies', 'List assemblies' do |sc|
          sc.action do 
            Operation::Module.list_assemblies
          end
        end
      end

      subcommand_def 'delete' do |c|
        c.desc 'Delete DTK module'
        command_body c, :delete, 'Delete DTK module' do |sc|
          sc.flag Term::Flag.namespace_module_name unless context_attributes[:module_ref]
          sc.switch [:y], :desc => 'Skip prompt'
          sc.action do |_global_options, options, args|
            unless module_ref = options[:namespace_module_name] || context_attributes[:module_ref]
              # This error only applicable if not in module
              raise Error::Usage, "The module reference must be given using option ''#{option_ref(:namespace_module_name)}'"
            end
            Operation::Module.delete(:module_ref => module_ref, :force => options[:y])
          end
        end
      end
    end
  end
end; end
