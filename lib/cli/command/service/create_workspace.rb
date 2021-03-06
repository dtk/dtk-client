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
      subcommand_def 'create-workspace' do |c|
        c.arg Token::Arg.workspace_name, :optional => true
        command_body c, 'create-workspace', 'Create empty workspace' do |sc|
          sc.flag Token.parent_service_instance
          sc.action do |_global_options, options, args|
            args = {
              :workspace_name => args[0],
              :target_service  => options[:parent_service_instance]
            }
            Operation::Service.create_workspace(args)
          end
        end
      end
    end
  end
end; end
