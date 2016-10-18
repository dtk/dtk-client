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
    module Module
      subcommand_def 'list-remotes' do |c|
        command_body c, 'list-remotes', 'List remote modules' do |sc|
          sc.flag Token.namespace
          sc.action do |_global_options, options, args|
            arg = {}
            unless options[:n].nil?
              arg = {
                :module_namespace => options[:n]
              }
            end
            
            Operation::Module.list_remotes(arg)
          end
        end
      end

    end
  end
end