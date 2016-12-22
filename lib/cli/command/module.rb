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
      module Module 
        include Command::Mixin

        ALL_SUBCOMMANDS = ['install', 'list', 'list-assemblies', 'push', 'uninstall', 'clone', 'list-remotes', 'push-dtkn', 'stage', 'pull-dtkn']
        command_def :desc => 'Subcommands for interacting with DTK modules'
        ALL_SUBCOMMANDS.each { |subcommand| require_relative("module/#{subcommand.gsub(/-/,'_')}") } 
      end
    end
  end
end

