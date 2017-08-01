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
        c.arg Token::Arg.target_directory, :optional => true
        command_body c, :install, 'Install a module on the server from a client directory or from the DTK remote catalog (DTKN)' do |sc|
          sc.flag Token.version
          # Add '-d' flag if development mode is active
          if Config[:development_mode]
            sc.flag Token.directory_path, :desc => 'Absolute or relative path to directory containing content to install'
          end
          sc.switch Token.update_deps

          sc.action do |_global_options, options, args|
            directory_path = args[1] || options[:directory_path]
            version        = options[:version]
            update_deps    = options[:update_deps]
            has_remote_repo = false
          
            if module_name = args[0]
              # reached if installing from dtkn
              # installs content from dtkn (later probably from other remote catalogs) onto client machine
              # in so doing installes depedent modules onto teh dtk server; this step though does not install main module onto
              # server (the later step Operation::Module.install does this)
              has_remote_repo = true
              module_ref = module_ref_object_from_options_or_context?(:module_ref => module_name, :version => version)
              target_repo_dir = Operation::Module.install_from_catalog(:module_ref => module_ref, :version => options[:version], :directory_path => directory_path)
            end

            raise Error::Usage, "You can use version only with 'namespace/name' provided" if version && module_name.nil?

            if target_repo_dir
              directory_path ||= target_repo_dir.data[:target_repo_dir]
            end

            install_opts = directory_path ? { :directory_path => directory_path, :version => (version || 'master') } : options
            module_ref   = module_ref_object_from_options_or_context?(install_opts)
            operation_args = {
              :module_ref          => module_ref, 
              :base_dsl_file_obj   => @base_dsl_file_obj, 
              :has_directory_param => !options["d"].nil?,
              :has_remote_repo     => has_remote_repo,
              :update_deps         => update_deps
            }
            Operation::Module.install(operation_args)
          end
        end
      end
    end
  end
end

