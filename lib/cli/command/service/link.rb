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
      subcommand_def 'link' do |c|
        c.arg Token::Arg.base_cmp
        c.arg Token::Arg.deps_on_cmp
        c.arg Token::Arg.service, :optional => true
        command_body c, 'link', 'List component links in the service instance.' do |sc|
          sc.flag Token.directory_path, :desc => 'Absolute or relative path to service instance directory containing updates to pull; not need if in the service instance directory'
          sc.flag Token.link_name
          sc.switch Token.unlink

          sc.action do |_global_options, options, _args|
            base_component      = _args[0]
            dependent_component = _args[1]
            service             = _args[2]
            service_instance    =  service_instance_in_options_or_context(options) 
            link_name           = options[:l] unless options[:l].nil?

            args = {
              :service_instance    => service_instance,
              :unlink              => options["u"],
              :base_component      => base_component,
              :dependent_component => dependent_component,
              :service             => service,
              :link_name           => link_name
            }

            Operation::Service.link(args)
          end
        end
      end
    end
  end
end; end