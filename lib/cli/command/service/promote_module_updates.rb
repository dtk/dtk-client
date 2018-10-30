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
      subcommand_def 'promote-module-updates' do |c|
        c.arg Token::Arg.module_name, optional: true
        command_body c, 'promote-module-updates', 'Promote updates from nested to base module' do |sc|
          sc.switch Token.force
          sc.action do |_global_options, options, args|
            args = {
              service_instance: service_instance_in_options_or_context(options),
              module_name: args[0],
              directory_path: @base_dsl_file_obj.parent_dir,
              command: 'promote-module-updates',
              force: options[:f]
            }
            Operation::Service.promote_module_updates(args)
          end
        end
      end
    end
  end
end; end