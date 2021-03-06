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
      subcommand_def 'clone' do |c|
        c.arg Token::Arg.service_instance
        c.arg Token::Arg.target_directory, :optional => true
        command_body c, :clone, 'Clone content of service module from server to client' do |sc|
          sc.action do |_global_options, options, args|
            service_name = args[0]
            service_ref  = service_instance_in_options_or_context(:service_instance => service_name, :version => options[:version])

            arg = {
              :service_ref       => service_ref,
              :service_name      => service_name,
              :target_directory  => args[1]
            }

            Operation::Service.clone_service(arg)
          end
        end
      end

    end
  end
end

