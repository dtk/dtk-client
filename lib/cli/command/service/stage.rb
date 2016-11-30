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
        c.arg Token::Arg.assembly_name, :optional => true
        command_body c, :stage, 'Create a new service instance to refer to staged infrastructure that then can be deployed' do |sc|
          sc.flag Token.directory_path, :desc => 'Path to module directory where assembly is being staged from; not needed if in the module directory'
          sc.flag Token.service_name, :desc => 'If specified, name to use for new service instance; otherwise service instance name is auto-generated' 
          sc.flag Token.parent_service_instance
          sc.switch Token.force
          sc.switch Token.target
          # on useful for testing in dev mode
          # sc.switch Token.purge, :desc => 'Overwrite any content that presently exists in the service instance directory to be created'
          #  sc.flag Token.version
          sc.action do |_global_options, options, args|
            module_ref     = module_ref_in_options_or_context(options)
            assembly_name  = args[0]
            version        = options[:version] || module_ref.version
            service_name   = options[:service_name]
            force          = options[:f]
            directory_path = options[:directory_path]

            Validation.validate_name(service_name) if service_name

            args = {
              :module_ref      => module_ref,
              :assembly_name   => assembly_name,
              :service_name    => service_name,
              :version         => version,
              :target_service  => options[:parent_service_instance],
              :remove_existing => options[:purge],
              :is_target       => options[:target],
              :force           => force,
              :directory_path  => directory_path
            }
            Operation::Service.stage(args)
          end
        end
      end
    end
  end
end
