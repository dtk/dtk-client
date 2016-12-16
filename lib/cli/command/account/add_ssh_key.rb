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
    module Account
      subcommand_def 'add-ssh-key' do |c|
        c.arg Token::Arg.keypair_name
        command_body c, 'add-ssh-key', 'Adds SSH key for current user' do |sc|
          sc.flag Token.directory_path
          sc.action do |_global_options, options, args|
            directory_path = options[:directory_path]
            name           = args[0]
            args = {
              :diretory_path => directory_path,
              :name          => name
            }

            Operation::Account.add_ssh_key(args)
          end
        end
      end

    end
  end
end