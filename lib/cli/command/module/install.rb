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
        c.arg Token::Arg.module_name, :optional => true
        command_body c, :install, 'Install contents of client directory to be a module on the server' do |sc|
          sc.flag Token.version
          sc.flag Token.directory_path, :desc => 'Absolute or relative path to directory containing content to install'
          sc.action do |_global_options, options, args|
            directory_path = options[:directory_path]
            version = options[:version]

            # install from dtkn (later probably from other remote catalogs)
            if module_name = args[0]
              module_ref = module_ref_in_options_or_context?(:module_ref => module_name, :version => (version || 'master'))
              target_repo_dir = Operation::Module.install_from_catalog(:module_ref => module_ref, :version => options[:version], :directory_path => directory_path)
            end

            raise Error::Usage, "You can use version only with 'namespace/name' provided" if version && module_name.nil?

            if target_repo_dir
              directory_path ||= target_repo_dir.data[:target_repo_dir]
            end

            install_opts = directory_path ? { :directory_path => directory_path, :version => (version || 'master') } : options
            module_ref = module_ref_in_options_or_context?(install_opts)
            Operation::Module.install(:module_ref => module_ref, :base_dsl_file_obj => @base_dsl_file_obj)
          end
        end
      end
    end
  end
end

