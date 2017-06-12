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
      subcommand_def 'exec-sync' do |c|
        c.arg Token::Arg.action
        c.arg Token::Arg.action_params, :optional => true
        command_body c, 'exec-sync', 'Execute action synchronously' do |sc|
         sc.flag Token.directory_path, :desc => 'Absolute or relative path to service instance directory containing updates to pull; not need if in the service instance directory'
          sc.action do |_global_options, options, args|
            service_instance = service_instance_in_options_or_context(options)
            
            action        = args[0]
            action_params = args[1]
            directory_path = options[:d] || @base_dsl_file_obj.parent_dir

            args = {
              :service_instance => service_instance,
              :action           => action,
              :action_params    => action_params,
              :directory_path   => directory_path,
              :command          => 'exec-sync'
            }
            response = Operation::Service.exec(args)

            unless response.ok?
              response
            else
              if response.data(:empty_workflow)
                Response::Ok.new
              elsif violation_response = Violation.process_violations?(response)
                violation_response
              else
                Operation::Service.task_status(args.merge(:mode => 'stream'))
              end
            end
          end
        end
      end
    end
  end
end
