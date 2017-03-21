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
      subcommand_def 'delete-from-remote' do |c|
        c.arg Token::Arg.module_name
        command_body c, 'delete-from-remote', 'Delete module from the DTK remote catalog (DTKN)' do |sc|
          sc.flag Token.version
          sc.switch Token.skip_prompt
          
          sc.action do |_global_options, options, args|
            module_ref = module_ref_object_from_options_or_context?(:module_ref => args[0], :version => options[:version])
            operation_args = {
              :module_ref  => module_ref,
              :skip_prompt => options[:skip_prompt]
              # :force     => options[:f]
            }
            Operation::Module.delete_from_remote(operation_args)
          end
        end
      end
    end
  end
end

