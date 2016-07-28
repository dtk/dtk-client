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
      subcommand_def 'stage' do |c|
        c.arg 'ASSEMBLY-NAME'
        command_body c, :stage, 'Stage a new service instance from an assembly' do |sc|
          unless context_attributes[:module_ref]
            sc.flag Token.namespace_module_name
          end
          sc.flag Token.service_instance, :desc => 'If specified, new service instance name' 
          sc.flag Token.target_service_instance, :desc => 'Target service instance providing the context for the staged assembly' 
          sc.switch Token.force, :desc => 'Overwrite any content that presently exists in the service instance directory to be created'
          unless context_attributes[:module_ref]
            sc.flag Token.version
          end
          # sc.switch ['auto-complete'], :default_value => true, :desc => 'If true, components with dependencies are automatically linked'
          sc.action do |_global_options, options, args|
            in_module =  !!context_attributes[:module_ref]
            unless module_ref = options[:namespace_module_name] || context_attributes[:module_ref]
              # This error only applicable if not in module
              raise Error::Usage, "The module reference must be given using option ''#{option_ref(:namespace_module_name)}'"
            end

            assembly_name = args[0]
            version = options[:version] || (in_module ? 'master' : nil)
            args = {
              :module_ref     => module_ref,
              :assembly_name  => assembly_name,
              :service_name   => options[:service_instance],
              :version        => version,
              :target_service => options[:target_service_instance],
              :remove_existing => options[:force]
            }
            Operation::Service.stage(args)
          end
        end
      end
    end
  end
end; end
