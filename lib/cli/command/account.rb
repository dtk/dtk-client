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
  module CLI
    module Command
      module Account 
        include Command::Mixin

        ALL_SUBCOMMANDS = [
          'list-ssh-keys',
          'delete-ssh-key',
          'add-ssh-key',
          'set-password',
          'set-catalog-credentials',
          'register-catalog-user',
          'add-to-group',
          'remove-from-group',
          'create-namespace',
          'chmod',
          'delete-namespace',
          'list-namespaces'
        ]
        command_def :desc => 'Subcommands for interacting with current Account'
        ALL_SUBCOMMANDS.each { |subcommand| require_relative("account/#{subcommand.gsub(/-/,'_')}") } 
      end
    end
  end
end

