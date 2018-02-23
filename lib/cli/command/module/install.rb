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
          sc.switch Token.update_lock
          
          sc.action do |_global_options, options, args|
            module_name         = args[0]
            directory_path      = args[1] || options[:directory_path]
            has_directory_param = !options['d'].nil?

            opts_hash = {
              module_name: module_name,
              directory_path: directory_path,
              version: options[:version],
              update_deps: options[:update_deps],
              has_directory_param: has_directory_param,
              update_lock_file: options['update-lock']
            }
            Install.execute(self, opts_hash)
            nil
          end
        end

        # TODO: 3070: in sprint 7 should move a lot of this logic into the install operation directoty and use commands/moduel/install just to get params
        class Install
          def initialize(context, opts = {})
            @context             = context
            @module_name         = opts[:module_name]
            @explicit_version    = opts[:version]
            @update_deps         = opts[:update_deps]
            @directory_path      = opts[:directory_path]
            @has_directory_param = opts[:has_directory_param]
            @update_lock_file    = opts[:update_lock_file]
          end
          
          def self.execute(context, opts = {})
            new(context, opts).execute
          end
          
          def execute
            if @module_name
              if Operation::Module.module_version_exists?(self.module_ref)
                clone_module
              else
                install_from_catalog
              end
            else
              install_from_directory
            end
          end
          
          protected
          
          attr_reader :context

          def module_ref
            @module_ref ||= ret_module_ref
          end

          def version
            @version ||= self.module_ref.version
          end

          def base_dsl_file_obj
            @base_dsl_file_obj ||= self.context.base_dsl_file_obj
          end

          OPTIONAL_vars = [:module_name, :explicit_version, :update_deps, :directory_path, :has_directory_param]
          OPTIONAL_vars.each { |var| class_eval("def #{var}?; @#{var}; end") }
          
          private

          def install_from_catalog
            # installs content from dtkn (later probably from other remote catalogs) onto client machine
            # in so doing installes dependent modules onto teh dtk server; this step though does not install main module onto
            # server (the later step Operation::Module.install does this)
            
            # TODO: 3070: handle sitution where response is not ok
            install_response = Operation::Module.install_from_catalog(module_ref: self.module_ref, version: self.version, directory_path: self.directory_path?)
            
            if client_installed_modules = (install_response && install_response.data[:installed_modules])
              opts_server_install = {
                has_directory_param: self.has_directory_param?,
                has_remote_repo: true,
                update_deps: self.update_deps?,
                install_from: :remote
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
            get_and_install_dependencies
            Operation::Module.install(operation_args)
          end

          def get_and_install_dependencies
            file_obj = nil
            if self.has_directory_param?
              file_obj = self.base_dsl_file_obj.raise_error_if_no_content_flag(:module_ref)
            else
              file_obj = self.base_dsl_file_obj.raise_error_if_no_content
            end

            module_info = {
              name:      self.module_ref.module_name,
              namespace: self.module_ref.namespace,
              version:   self.module_ref.version,
              repo_dir:  file_obj.parent_dir
            }
            parsed_module   = file_obj.parse_content(:common_module_summary)
            dependency_tree = Operation::DtkNetworkDependencyTree.get_or_create(module_info, { format: :hash, parsed_module: parsed_module, save_to_file: true, update_lock_file: @update_lock_file })

            dependency_tree.each do |dependency|
              dep_module_ref = module_ref_object_from_options_or_context(module_ref: "#{dependency[:namespace]}/#{dependency[:name]}", version: dependency[:version])
              if Operation::Module.module_version_exists?(dep_module_ref)
                p_helper = Operation::Module::Install::PrintHelper.new(:module_ref => dep_module_ref, :source => :local)
                p_helper.print_using_installed_dependent_module
              else
                client_installed_modules = nil

                if dependency[:source]
                  client_installed_modules = [dependency]
                else
                  install_response = Operation::Module.install_from_catalog(module_ref: dep_module_ref, version: dep_module_ref.version, type: :dependency)
                  client_installed_modules = (install_response && install_response.data[:installed_modules])
                end

                if client_installed_modules# = (install_response && install_response.data[:installed_modules])
                  install_from = dependency[:source] ? :local : :remote
                  opts_server_install = {
                    has_directory_param: false,
                    has_remote_repo: true,
                    update_deps: self.update_deps?,
                    install_from: install_from
                  }
                  install_on_server(client_installed_modules, opts_server_install)
                end
              end
            end
          end
          
          # opts can have keys:
          #   :has_directory_param,
          #   :has_remote_repo
          #   :update_dep
          def install_on_server(client_installed_modules, opts = {})
            client_installed_modules.each do |installed_module|
              directory_path = installed_module[:location] || installed_module[:source]
              module_ref     = module_ref_object_from_options_or_context(directory_path: directory_path, version: installed_module[:version])
              use_or_install_on_server(module_ref, directory_path, opts)
            end
          end

          def use_or_install_on_server(module_ref, directory_path, opts = {})
            if Operation::Module.module_version_exists?(module_ref)
              p_helper = Operation::Module::Install::PrintHelper.new(:module_ref => module_ref, :source => :local)
              p_helper.print_using_installed_dependent_module
            else
              base_dsl_file_obj = CLI::Context.base_dsl_file_obj(dir_path: directory_path)
              operation_args = {
                :module_ref          => module_ref,
                :base_dsl_file_obj   => base_dsl_file_obj,
                :has_directory_param => opts[:has_directory_param],
                :has_remote_repo     => opts[:has_remote_repo],
                :update_deps         => opts[:update_dep],
                :install_from        => opts[:install_from]
              }
              Operation::Module.install(operation_args)
            end
          end

          def clone_module
            # clone module into current directory + module name; same as when installing base module from dtk-network
            target_directory_path = self.directory_path? || "#{OsUtil.current_dir}/#{self.module_ref.module_name}"
            arg = {
              :module_ref => self.module_ref,
              :target_directory => Operation::ClientModuleDir.create_module_dir_from_path(target_directory_path)
            }
            repo_dir_info = Operation::Module.clone_module(arg).data
            OsUtil.print_info("DTK module '#{self.module_ref.pretty_print}' has been successfully cloned from server into '#{repo_dir_info[:target_repo_dir]}'")
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
              module_ref_version_unset = module_ref_object_from_options_or_context(module_ref: self.module_name?, version: @explicit_version)
              fill_in_version_from_server_or_remote!(module_ref_version_unset) unless @explicit_version
              module_ref_version_unset
            else
              module_ref_object_from_options_or_context(directory_path: self.directory_path?)
            end
          end

          # opts can have keys
          #   :module_ref
          #   :version
          #   :directory_path
          def module_ref_object_from_options_or_context(opts = {})
            self.context.module_ref_object_from_options_or_context(opts)
          end

          def fill_in_version_from_server_or_remote!(module_ref_version_unset)
            module_ref = module_ref_version_unset

            module_info = {
              name: module_ref.module_name,
              namespace: module_ref.namespace,
            }

            begin
              versions = Operation::Module::DtkNetworkClient::Info.run(module_info, about: :versions)
            rescue Exception => e
              # if does not exist on repoman try getting version from server
              versions = get_versions_from_server(module_ref)
            end

            if versions.empty?
              raise Error::Usage, "Module '#{module_term(module_ref)}' does not exist." 
            elsif version = self.explicit_version?
              if versions.include?(version)
                module_ref.version = version
              else
                legal_versions = versions.join(', ')
                raise Error::Usage, "Module '#{module_term(module_ref)}' does not have specified version '#{version}'; legal versions are: #{legal_versions}"
              end
            else
              # use latest version
              module_ref.version = find_latest_version(versions)
            end
            module_ref
          end

          def module_term(module_ref)
            "#{module_ref.namespace}:#{module_ref.module_name}"
          end

          def find_latest_version(versions)
            if versions.size > 1
              versions.delete('master')
              versions.sort.last
            else
              versions.first
            end
          end

          def get_versions_from_server(module_ref)
            query_string_hash = QueryStringHash.new(
              :module_name => module_ref.module_name,
              :namespace   => module_ref.namespace
            )
            response = Operation::Module.rest_get("#{Operation::Module::BaseRoute}/versions", query_string_hash)
            versions = response.data(:versions) || []

            versions
          end
        end
      end
    end
  end
end
