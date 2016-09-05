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
      subcommand_def 'uninstall' do |c|
        command_body c, :uninstall, 'Uninstall module from server' do |sc|
          sc.switch Token.skip_prompt, :desc => 'Skip prompt that checks if user wants to uninstall module from server'
          sc.flag Token.directory_path
          sc.flag Token.version
          sc.action do |_global_options, options, _args|
            module_ref = module_ref_in_options_or_context(options)
            Operation::Module.uninstall(:module_ref => module_ref, :skip_prompt => options[:skip_prompt])
          end
        end
      end

    end
  end
end
