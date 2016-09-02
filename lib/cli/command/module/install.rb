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
      subcommand_def 'install' do |c|
        # c.arg Token::Arg.module_name, :optional => true
        command_body c, :install, 'Install contents of client directory to be a module on the server' do |sc|
          sc.flag Token.version
          sc.flag Token.directory_path, :desc => 'Absolute or relative path to directory containing content to install'
          sc.action do |_global_options, options, args|
            # install from dtkn (later probably from other remote catalogs)
            if module_name = args[0]
              module_ref = module_ref_in_options_or_context?(:module_ref => module_name)
              Operation::Module.install_from_catalog(:module_ref => module_ref, :version => options[:version], :directory_path => options[:directory_path])
            end

            module_ref = module_ref_in_options_or_context?(options)
            Operation::Module.install(:module_ref => module_ref, :base_dsl_file_obj => @base_dsl_file_obj)#, :directory_path => options[:directory_path])
          end
        end
      end
    end
  end
end

