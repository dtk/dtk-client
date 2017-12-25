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
            module_name         = args[0]
            directory_path      = args[1] || options[:directory_path]
            has_directory_param = !options['d'].nil?,
            Install.execute(self,  module_name: module_name, directory_path: directory_path, version: options[:version], update_deps: options[:update_deps], has_directory_param: has_directory_param)
            nil
          end
        end

        # TODO: 3070: in sprint 7 should move alot of this logic into the install opration dircetoty and use commands/moduel/install just to get params
        class Install
          def initialize(context, opts = {})
            @context             = context
            @module_name         = opts[:module_name]
            @explicit_version    = opts[:version]
            @update_deps         = opts[:update_deps]
            @directory_path      = opts[:directory_path]
            @has_directory_param = opts[:has_directory_param]
          end
          
          def self.execute(context, opts = {})
            new(context, opts).execute
          end
          
          def execute
            set_module_ref_and_version!

            if Operation::Module.module_version_exists?(self.module_ref)
              clone_module
            else
              if should_install_from_catalog?
                install_from_catalog
              else
                install_from_directory
              end
            end
          end
          
          protected
          
          attr_reader :context

          def module_ref
            @module_ref ||= ret_module_ref
          end

          def version
            @version ||= ret_version
          end

          def base_dsl_file_obj
            @base_dsl_file_obj ||= self.context.base_dsl_file_obj
          end

          OPTIONAL_vars = [:module_name, :explicit_version, :update_deps, :directory_path, :has_directory_param]
          OPTIONAL_vars.each { |var| class_eval("def #{var}?; @#{var}; end") }
          
          private

          def install_from_catalog
            # installs content from dtkn (later probably from other remote catalogs) onto client machine
            # in so doing installes depedent modules onto teh dtk server; this step though does not install main module onto
            # server (the later step Operation::Module.install does this)
            
            # TODO: 3070: handle sitution where response is not ok
            #  TODO: 3070: removed remote_module_info becuase looke dlike alwys nil

            install_response = Operation::Module.install_from_catalog(module_ref: self.module_ref, version: self.version, directory_path: self.directory_path?)
            #install_response = Operation::Module.install_from_catalog(:module_ref => self.module_ref, :version => version, :directory_path => self.directory_path?, :remote_module_info => remote_module_info)
            
            # raise Error::Usage, "You can use version only with 'namespace/name' provided" if version && module_name.nil?
            
            # if target_repo_dir
            #   directory_path ||= target_repo_dir.data[:target_repo_dir]
            # end
            
            if client_installed_modules = (install_response && install_response.data[:installed_modules])
              opts_server_install = {
                has_directory_param: self.has_directory_param?,
                has_remote_repo: true,
                update_deps: self.update_deps?
              }
              install_on_server(client_installed_modules, opts_server_install)
            end
          end
        
          def install_from_directory
            operation_args = {
              :module_ref          => self.module_ref,
              :base_dsl_file_obj   => self.base_dsl_file_obj,
              :has_directory_param => self.has_directory_param?,
              :has_remote_repo     => false,
              :update_deps         => self.update_deps?
            }
            Operation::Module.install(operation_args)
            # TODO: DTK-3370: assume that right here goes the logic to recursively store the dependencies 
          end
          
          # opts can have keys:
          #   :has_directory_param,
          #   :has_remote_repo
          #   :update_dep
          def install_on_server(client_installed_modules, opts = {})
            client_installed_modules.each do |installed_module|
              directory_path    = installed_module[:location]
              module_ref        = module_ref_object_from_options_or_context(directory_path: directory_path, version: installed_module[:version])
              # TODO: DTK-3370: put in logic that sees if module_ref is isnatlled on server and skips Operation::Module.install if it is
              base_dsl_file_obj = CLI::Context.base_dsl_file_obj(dir_path: directory_path)
              
              operation_args = {
                :module_ref          => module_ref,
                :base_dsl_file_obj   => base_dsl_file_obj,
                :has_directory_param => opts[:has_directory_param],
                :has_remote_repo     => opts[:has_remote_repo],
                :update_deps         => opts[:update_dep]
              }
              Operation::Module.install(operation_args)
            end
          end

          def clone_module
            fail "DTK-3370: 'clone when module exists on server' needs to be refactored"
            # TODO: DTK-3370: this can be defered to sprint 7; need to figure out what directory to clone to; logic below is just copied from what was essentially in curret code as opposed to be written to be right" 
            arg = {
              :module_ref => self.module_ref,
              :target_directory => Operation::ClientModuleDir.create_module_dir_from_path(self.directory_path? || OsUtil.current_dir)
            }
            repo_dir_info = Operation::Module.clone_module(arg).data
            repo_dir      = repo_dir_info[:target_repo_dir]

            # DTK-3088 - need this to pull service info for dependency module on clone
            if repo_dir_info[:pull_service_info]# && (version.nil? || version.eql?('master'))
              repo_dir = repo_dir_info[:target_repo_dir]
              module_ref = module_ref_object_from_options_or_context(:directory_path => repo_dir)
              
              operation_args = {
                :module_ref          => self.module_ref,
                :base_dsl_file_obj   => self.base_dsl_file_obj,
                :has_directory_param => true,
                :directory_path      => repo_dir,
                :update_deps         => false,
                :do_not_print        => true,
                :force               => true,
                :allow_version       => true
              }
              
              Operation::Module.pull_dtkn(operation_args)
              Operation::Module.push(operation_args.merge(:method => "pulled"))
            end
            
            OsUtil.print_info("DTK module '#{module_ref.pretty_print}' has been successfully cloned from server into '#{repo_dir}'")
          end
          
          # This is needed because once version is set need it to update module ref
          def set_module_ref_and_version!
            # order matters
            self.module_ref
            self.version
            nil
          end

          def should_install_from_catalog?
            unless @install_from_catalog.nil?
              @install_from_catalog
            else
              @install_from_catalog = !!self.module_name?
            end
          end

          def ret_module_ref
            if should_install_from_catalog?
              module_ref_object_from_options_or_context(module_ref: self.module_name?, version: self.explicit_version?)
            else
              # TODO: DTK-3370; if self.directory_path? is nil think we might need to pass some params to module_ref_object_from_options_or_context
              version  = self.explicit_version? ||  version_when_from_directory
              install_opts = self.directory_path? ? { directory_path: self.directory_path?, version: version } : {}
              module_ref_object_from_options_or_context(install_opts)
            end
          end

          # opts can have keys
          #   :module_ref
          #   :version
          #   :directory_path
          def module_ref_object_from_options_or_context(opts = {})
            self.context.module_ref_object_from_options_or_context(opts)
          end

          DEFAULT_VERSION_WHEN_ON_DIR = 'master'
          def ret_version 
            version = 
              if self.explicit_version?
                self.explicit_version?
              elsif should_install_from_catalog?
                version_from_remote
              else
                version_when_from_directory
              end
            self.module_ref.version = version
          end

          def version_when_from_directory
            DEFAULT_VERSION_WHEN_ON_DIR
          end

          def version_from_remote
            versions = get_remote_module_info(self.module_ref, about: :versions)
            raise Error::Usage, "Module '#{self.module_ref.namespace}/#{self.module_ref.module_name}' does not have any versions." if versions.empty?
            versions.sort.last
          end

          # opts can have keys:
          #   :about
          def get_remote_module_info(module_ref, opts = {})
            module_info = {
              name: module_ref.module_name,
              namespace: module_ref.namespace,
            }
            Operation::Module::DtkNetworkClient::Info.run(module_info, about: opts[:about])
          end        
        
        end
      end
    end
  end
end
