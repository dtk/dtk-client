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
      subcommand_def 'delete' do |c|
        command_body c, :delete, 'Delete DTK module from server' do |sc|
          sc.flag Token.namespace_module_name, :default_value => "Directory where executing from"
          sc.switch Token.skip_prompt, :desc => 'Skip prompt that checks if user wants to delete module'
          sc.action do |_global_options, options, args|
            unless module_ref = options[:namespace_module_name] || context_attributes[:module_ref]
              # This error only applicable if not in module
              raise Error::Usage, "The module reference must be given using option ''#{option_ref(:namespace_module_name)}'"
            end
            Operation::Module.delete(:module_ref => module_ref, :skip_prompt => options[:skip_prompt])
          end
        end
      end

    end
  end
end
