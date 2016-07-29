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
  module CLI::Command
    module Service
      subcommand_def 'stage' do |c|
        c.arg Token::Arg.assembly_name
        command_body c, :stage, 'Stage a new service instance from an assembly' do |sc|
          sc.flag Token.namespace_module_name, :desc => 'Module name with namespace from which to find assembly; not needed if command is executed from within the module'
          sc.flag Token.service_instance, :desc => 'If specified, new service instance name' 
          sc.flag Token.parent_service_instance
          sc.switch Token.purge, :desc => 'Overwrite any content that presently exists in the service instance directory to be created'
          unless context_attributes[:module_ref]
            sc.flag Token.version
          end
          # sc.switch ['auto-complete'], :default_value => true, :desc => 'If true, components with dependencies are automatically linked'
          sc.action do |_global_options, options, args|
            in_module =  !!context_attributes[:module_ref]
            module_ref = module_ref_in_context_or_options(options)
            assembly_name = args[0]
            version = options[:version] || (in_module ? 'master' : nil)
            args = {
              :module_ref      => module_ref,
              :assembly_name   => assembly_name,
              :service_name    => options[:service_instance],
              :version         => version,
              :target_service  => options[:parent_service_instance],
              :remove_existing => options[:purge]
            }
            Operation::Service.stage(args)
          end
        end
      end
    end
  end
end
