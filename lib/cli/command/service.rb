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
      module Service
        require_relative('service/violation')

        include Command::Mixin
        ALL_SUBCOMMANDS = [
          'cancel-task',
          'clone',
          'converge',
          'delete',
          'edit',
          'eject',
          'exec',
          'exec-sync',
          'link',
          'list',
          'list-actions',
          'list-attributes',
          'list-component-links',
          'list-components',
          'list-dependencies',
          'list-nodes',
          'list-violations',
          'pull',
          'push',
          'set-attribute',
          'set-default-target',
          'set-required-attributes',
          'ssh',
          # TODO: put back in
          #  'start',
          #  'stop',

          'task-status',
          'uninstall',
          'describe'
          # 'add'
        ]

        command_def :desc => 'Subcommands for creating and interacting with DTK service instances'
        ALL_SUBCOMMANDS.each { |subcommand| require_relative("service/#{subcommand.gsub(/-/,'_')}") } 
      end
    end
  end
end

