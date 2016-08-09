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
      subcommand_def 'destroy' do |c|
        command_body c, :destroy, 'Destroys the running infrastructure associated with the service instance and uninstalls the service instance from the server' do |sc|
        sc.flag Token.directory_path, :desc => 'Absolute or relative path to service instance directory associated; not needed if executed in service instance directory'
          sc.switch Token.skip_prompt, :desc => 'Skip prompt that checks if user wants to delete the service instance'
          sc.switch Token.purge, :desc => 'Delete the service instance directory on the client'
          sc.action do |_global_options, options, args|
            directory_path = options[:directory_path]
            purge          = options[:purge]

            if purge && (!directory_path || (directory_path == @base_dsl_file_obj.parent_dir))
              raise Error::Usage, "If use option '#{option_ref(:purge)}' then need to call from outside directory and use option '#{option_ref(:directory_path)}'"
            end
            service_instance = service_instance_in_options_or_context(options)

            args = {
              :service_instance => service_instance,
              :skip_prompt      => options[:skip_prompt],
              :directory_path   => directory_path,
              :purge            => purge
            }
            Operation::Service.destroy(args)
          end
        end
      end
    end
  end
end; end
