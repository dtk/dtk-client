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
      subcommand_def 'ssh' do |c|
        c.arg Token::Arg.node_name
        command_body c, :ssh, 'Ssh into service instance node.' do |sc|
          sc.flag Token.remote_user
          sc.flag Token.identity_file, :desc => 'Identity file used for connection, if not provided default is used'

          sc.action do |_global_options, options, args|
            service_instance = service_instance_in_options_or_context(options)

            args = {
              :service_instance => service_instance,
              :node_name        => args[0],
              :remote_user      => options[:remote_user],
              :identity_file    => options[:identity_file]
            }
            Operation::Service.ssh(args)
          end
        end
      end
    end
  end
end
