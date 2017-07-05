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
      subcommand_def 'set-attribute' do |c|
        c.arg Token::Arg.attribute_name
        c.arg Token::Arg.attribute_value, :optional => true
        command_body c, 'set-attribute',  'Edit specific attribute.' do |sc|
          sc.switch Token.u
          sc.flag Token.directory_path
          sc.action do |_global_options, options, _args|

            service_instance = service_instance_in_options_or_context(options)

            attribute_name = _args[0]
            options[:u] ? attribute_value = nil : attribute_value = _args[1]

            options[:d].nil? ? service_instance_dir =  @base_dsl_file_obj.parent_dir : service_instance_dir = options[:d]

            args = {
              :attribute_name   => attribute_name,
              :service_instance => service_instance,
              :attribute_value  => attribute_value,
              :service_instance_dir => @base_dsl_file_obj.parent_dir
            }

            Operation::Service.set_attribute(args)
          end
        end
      end
    end
  end
end; end