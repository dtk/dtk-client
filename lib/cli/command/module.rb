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

      ALL_SUBCOMMANDS = ['install', 'list-assemblies']
      command_def :desc => 'Subcommands for interacting with DTK modules'

      subcommand_def 'install' do |c|
        unless context_attributes[:module_name]
          c.arg 'NAMESPACE/MODULE-NAME', :optional
        end
        c.desc 'Install DTK module'
        c.command :install  do |install|
          install.flag [:v, :version], :arg_name => 'VERSION', :desc => 'Module Version'
          install.switch [:f], :default_value => false, :desc => 'Force Install'
          install.action do |global_options, options, args|
            # pp [self.class, options, args, context_attributes: context_attributes]
            puts 'dtk module install'
          end
        end
      end

      subcommand_def 'list-assemblies' do |c|
        c.desc 'List assemblies'
        c.command 'list-assemblies'  do |list_assemblies|
          list_assemblies.action do 
            Execute::Module.list_assemblies
          end
        end
      end
    end
  end
end; end
