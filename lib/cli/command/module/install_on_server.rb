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
      subcommand_def 'install-on-server' do |c|
        c.arg Token::Arg.module_name
        command_body c, 'install-on-server', 'List assemblies from all modules or specified module' do |sc|
          sc.flag Token.version
          sc.action do |_global_options, options, args|
            version     = options[:version]
            module_name = args[0]
            module_ref  = module_ref_object_from_options_or_context?(:module_ref => module_name, :version => version)
            Operation::Module.install_on_server(:module_ref => module_ref)
          end
        end
      end

    end
  end
end
