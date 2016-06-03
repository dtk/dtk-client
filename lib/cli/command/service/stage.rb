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
        c.desc 'Stage a new service instance from an assembly'
        c.command :stage  do |sc|
          sc.flag [:m], :arg_name => 'NAMESPACE/MODULE-NAME', :desc => 'Module name with namespace', :default_value => context_attributes[:module_ref] 
          sc.flag [:i], :arg_name =>'INSTANCE-NAME', :desc => 'If specified, new service instance name' 
          sc.flag [:t], :arg_name => 'PARENT-SERVICE-INSTANCE', :desc => 'Parent Service instance providing the context for the staged assembly' 
          sc.flag [:v], :arg_name => 'VERSION', :desc => 'Version'
          # sc.switch ['auto-complete'], :default_value => true, :desc => 'If true, components with dependencies are automatically linked'
          sc.action do |_global_options, options, args|
            unless module_ref = options[:m]
              raise Error::Usage, "The module reference must be given using option '-m NAMESPACE/MODULE-NAME'"
            end
            module_ref  = ModuleRef.reify(module_ref)
            assembly_name = args[0]
            args = {
              :namespace     => module_ref.namespace, 
              :module_name   => module_ref.module_name, 
              :assembly_name => assembly_name,
              :instance_name => options[:i],
              :version       => options[:v],
              :target        => options[:t],
            }
            Operation::Service.stage(args)
          end
        end
      end
    end
  end
end; end
