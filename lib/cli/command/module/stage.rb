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
    module Module
      subcommand_def 'stage' do |c|
        c.arg Token::Arg.assembly_name, :optional => true
        command_body c, :stage, 'Create a new service instance to refer to staged infrastructure that then can be deployed' do |sc|
          sc.flag Token.directory_path, :desc => 'Path to module directory where assembly is being staged from; not needed if in the module directory'
          sc.flag Token.service_name, :desc => 'If specified, name to use for new service instance; otherwise service instance name is auto-generated' 
          sc.flag Token.comma_seperated_contexts
          sc.switch Token.force
          sc.switch Token.base
          sc.action do |_global_options, options, args|
            module_ref               = module_ref_object_from_options_or_context(options)
            assembly_name            = args[0]
            service_name             = options[:service_name]
            version                  = options[:version] || module_ref.version
            directory_path           = options[:directory_path] || @base_dsl_file_obj.parent_dir
            comma_seperated_contexts = options[:context]

            context_service_names = comma_seperated_contexts && Validation.process_comma_seperated_contexts(comma_seperated_contexts) 
            Validation.validate_name(service_name) if service_name

            args = {
              :module_ref            => module_ref,
              :assembly_name         => assembly_name,
              :service_name          => service_name,
              :version               => version,
              :context_service_names => context_service_names, 
              :remove_existing       => options[:purge],
              :is_base               => options[:base],
              :force                 => options[:f],
              :directory_path        => directory_path
            }
            Operation::Module.stage(args)
          end
        end
      end
    end
  end
end
