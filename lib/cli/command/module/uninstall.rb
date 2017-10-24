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
        c.arg Token::Arg.module_name, :optional => true
        command_body c, :uninstall, 'Uninstall module from server' do |sc|
          sc.switch Token.skip_prompt, :desc => 'Skip prompt that checks if user wants to uninstall module from server'
          sc.flag Token.directory_path
          sc.flag Token.version
          sc.flag Token.uninstall_name
          sc.switch Token.force
          sc.action do |_global_options, options, args|
            version = options[:version]
            force   = options["force"]

            module_refs_opts = {:ignore_parsing_errors => true}
            if options[:uninstall_name].nil?
              module_ref =
                if module_name = args[0]
                  module_ref_object_from_options_or_context?({:module_ref => module_name, :version => (version)}, module_refs_opts)
                else
                  module_ref_object_from_options_or_context(options, module_refs_opts)
                end
              else
                module_name = options["name"]
            end

            raise Error::Usage, "You can use version only with 'namespace/name' provided" if version && module_name.nil?

            Operation::Module.uninstall(:module_ref => module_ref, :force => force, :skip_prompt => options[:skip_prompt], :name => options[:uninstall_name] || module_name, :version => version)
          end
        end
      end

    end
  end
end
