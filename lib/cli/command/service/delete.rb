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
      subcommand_def 'delete' do |c|
        command_body c, :delete, 'Destroys the running infrastructure associated with the service instance' do |sc|
          sc.flag Token.delete_service_name
          sc.flag Token.directory_path, :desc => 'Absolute or relative path to service instance directory associated; not needed if executed in service instance directory'
          # sc.flag Token.path, :desc => "Delete specific part of service instance. Supported paths are 'dependencies/[name]', 'components/[name]', 'actions/[name]'"

          sc.switch Token.skip_prompt, :desc => 'Skip prompt that checks if user wants to delete the service instance'
          sc.switch Token.recursive, :desc => 'Delete all service instances staged into specified target'
          sc.switch Token.force, :desc => 'Ignore changes and destroy the running service instance'

          sc.action do |_global_options, options, args|
            directory_path   = options[:directory_path]
            recursive        = options[:recursive]
            force            = options[:f]
            name             = options[:delete_service_name]
            service_instance = name ? name : service_instance_in_options_or_context(options)
            
            args = {
              :service_instance => service_instance,
              :skip_prompt      => options[:skip_prompt],
              :recursive        => recursive,
              :force            => force,
              # :path             => options[:path]
            }
            args[:directory_path] = directory_path || base_dsl_file_obj.parent_dir unless name
            Operation::Service.delete(args)
          end
        end
      end
    end
  end
end; end
