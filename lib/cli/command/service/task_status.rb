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
      subcommand_def 'task-status' do |c|
        command_body c, 'task-status', "Get task status of the running or last running service instance task." do |sc|
          sc.flag Token.directory_path, :desc => 'Absolute or relative path to service instance directory; not needed if executed in the service instance directory'
          sc.flag Token.mode, :desc => 'Task status mode (snapshot, refresh, stream).'
          sc.action do |_global_options, options, _args|
            service_instance = service_instance_in_options_or_context(options)
            args = {
              :service_instance => service_instance,
              :mode             => options[:mode]
            }
            Operation::Service.task_status(args)
          end
        end
      end
    end
  end
end; end
