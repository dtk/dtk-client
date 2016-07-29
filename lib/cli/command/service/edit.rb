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
      subcommand_def 'edit' do |c|
        # since we are still using hardcoded path to spark module, we require service instance to be provided as parameter
        c.arg 'SERVICE-INSTANCE'
        c.arg 'RELATIVE-PATH', :optional
        command_body c, :edit, 'Edit service instance' do |sc|
          sc.switch Token.push, :desc => 'Commit and push changes to server'
          sc.flag Token.commit_message

          sc.action do |_global_options, options, args|
            args = {
              :module_ref        => context_attributes[:module_ref],
              :service_instance  => args[0],
              :relative_path     => args[1],
              :base_dsl_file_obj => @base_dsl_file_obj
            }
            Operation::Service.edit(args)
          end
        end
      end
    end
  end
end; end
