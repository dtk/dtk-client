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
        EDIT_DEFAULT_FILE = 'dtk.service.yaml'
        command_body c, :edit, "Call editor on selected file in service instance" do |sc|
          sc.flag Token.directory_path, :desc => 'Absolute or relative path to service instance directory; not needed if executed in the service instance directory'
          sc.flag Token.relative_path, :desc => "Relative path of file to edit in service instance directory if omitted then main dsl file '#{EDIT_DEFAULT_FILE}' is used"
          sc.flag Token.commit_message
          sc.switch Token.push, :desc => 'Commit and push changes made from editing to server'
          
          sc.action do |_global_options, options, _args|
            relative_path    = options[:relative_path] || EDIT_DEFAULT_FILE
            service_instance = service_instance_in_options_or_context(options)
            # @base_dsl_file_obj.parent_dir must go after ervice_instance_in_options_or_context, which can reset @base_dsl_file_obj
            module_directory = @base_dsl_file_obj.parent_dir

            args = {
              :service_instance   => service_instance,
              :absolute_file_path => "#{module_directory}/#{relative_path}",
              :commit_message     => options[:commit_message],
              :push_after_edit    => options[:push]
            }
            Operation::Service.edit(args)
          end
        end
      end
    end
  end
end; end
