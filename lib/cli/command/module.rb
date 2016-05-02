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
module DTK::CLI
  module Command
    module Module 
      include Command::Mixin

      command_def do
        desc 'Commands for interacting with DTK modules'
        command :module do |c|
          c.desc 'Installs a DTK module'
          c.command :install do |install|
            install.action do |global_options, options, args|
              pp [global_options, options, args]
              puts 'dtk module install'
            end
          end
        end
      end
    end
  end
end



