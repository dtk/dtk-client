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
      subcommand_def 'push' do |c|
        command_body c, :push, 'Commits and pushes any updated content in the client service instance directory to the server' do |sc|
          sc.flag Token.directory_path, :desc => 'Absolute or relative path to service instance directory containing where updates will be pulled; not needed if in the service instance directory'
          sc.flag Token.commit_message
          sc.action do |_global_options, options, _args|
            service_instance = service_instance_in_options_or_context(options)
            options[:d].nil? ? service_instance_dir =  @base_dsl_file_obj.parent_dir : service_instance_dir = options[:d]

            args = {
              :service_instance => service_instance,
              :commit_message   => options[:commit_message],
              :service_instance_dir => service_instance_dir
            }
            Operation::Service.commit_and_push(args)
          end
        end
      end
    end
  end
end; end
