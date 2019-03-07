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
  class Operation::Module
    class Push < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          module_ref        = args.required(:module_ref)
          method            = args[:method] || "pushed"
          allow_version     = args[:allow_version]
          base_dsl_file_obj = args.required(:base_dsl_file_obj)
          update_lock_file  = args[:update_lock_file]
          context           = args[:context]

          unless client_dir_path = module_ref.client_dir_path
            raise Error, "Not implemented yet; need to make sure module_ref.client_dir_path is set when client_dir_path given"
          end

          unless module_info = module_version_exists?(module_ref)
            raise Error::Usage, "DTK module '#{module_ref.print_form}' does not exist."
          end

          if ref_version = module_ref.version
            do_not_raise = allow_version || ref_version.eql?('master')
            raise Error::Usage, "You are not allowed to push module version '#{ref_version}'!" unless do_not_raise
          end

          branch    = module_info.required(:branch, :name)
          repo_url  = module_info.required(:repo, :url)
          repo_name = module_info.required(:repo, :name)

          @file_obj        = base_dsl_file_obj.raise_error_if_no_content
          parsed_module   = @file_obj.parse_content(:common_module_summary)
          repoman_client_module_info = {
            name:      module_ref.module_name,
            namespace: module_ref.namespace,
            version:   module_ref.version,
            repo_dir:  @file_obj.parent_dir
          }

          # response = Operation::Module.rest_get "modules/get_modules_versions_with_dependencies"
          # server_dependencies = response.data || []

          repoman_client_opts = {
            format: :hash,
            save_to_file: true,
            update_lock_file: update_lock_file
          }
          repoman_client_opts.merge!(parsed_module: parsed_module) unless method.eql?('pulled')
          dependency_tree = DtkNetworkDependencyTree.get_or_create(repoman_client_module_info, repoman_client_opts)

          # TODO: need to refactor to use the same code for push and install
          dependency_tree.each do |dependency|
            dep_module_ref = context.module_ref_object_from_options_or_context(module_ref: "#{dependency[:namespace]}/#{dependency[:name]}", version: dependency[:version])
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
                  # update_deps: self.update_deps?,
                  install_from: install_from
                }
                client_installed_modules.each do |installed_module|
                  directory_path = installed_module[:location] || installed_module[:source]
                  temp_module_ref     = context.module_ref_object_from_options_or_context(directory_path: directory_path, version: installed_module[:version])
                  # use_or_install_on_server(module_ref, directory_path, opts)
                  if Operation::Module.module_version_exists?(temp_module_ref)
                    p_helper = Operation::Module::Install::PrintHelper.new(:module_ref => temp_module_ref, :source => :local)
                    p_helper.print_using_installed_dependent_module
                  else
                    temp_base_dsl_file_obj = CLI::Context.base_dsl_file_obj(dir_path: directory_path)
                    operation_args = {
                      :module_ref          => temp_module_ref,
                      :base_dsl_file_obj   => temp_base_dsl_file_obj,
                      :has_directory_param => opts_server_install[:has_directory_param],
                      :has_remote_repo     => opts_server_install[:has_remote_repo],
                      :update_deps         => opts_server_install[:update_dep],
                      :install_from        => opts_server_install[:install_from]
                    }
                    Operation::Module.install(operation_args)
                  end
                end
                # install_on_server(client_installed_modules, opts_server_install)
              end
            end
          end

          git_repo_args = {
            :repo_dir      => module_ref.client_dir_path,
            :repo_url      => repo_url,
            :remote_branch => branch
          }
          git_repo_response = ClientModuleDir::GitRepo.create_add_remote_and_push(git_repo_args)
          # TODO: do we want below instead of above?
          # git_repo_response = ClientModuleDir::GitRepo.init_and_push_from_existing_repo(git_repo_args)

          post_body = PostBody.new(
            :module_name => module_info.required(:module, :name),
            :namespace   => module_info.required(:module, :namespace),
            :version?    => module_info.index_data(:module, :version),
            :repo_name   => repo_name,
            :commit_sha  => git_repo_response.data(:head_sha)
          )

          # response = handle_error @file_obj.parent_dir do
          #   rest_post("#{BaseRoute}/update_from_repo", post_body)
          # end

          response = rest_post("#{BaseRoute}/update_from_repo", post_body)

          existing_diffs = nil
          print          = nil
          if missing_dependencies = response.data(:missing_dependencies)
            force_parse = false
            unless missing_dependencies.empty?
              dependent_modules = missing_dependencies.map { |dependency| Install::ModuleRef.new(:namespace => dependency['namespace_name'], :module_name => dependency['display_name'], :version => dependency['version_info']) }
              begin
                Install::DependentModules.install(module_ref, dependent_modules, :update_none => true)
              rescue TerminateInstall
                @print_helper.print_terminated_installation
                return nil
              end
              existing_diffs = response.data(:existing_diffs)
              force_parse = true
            end
            response = rest_post("#{BaseRoute}/update_from_repo", post_body.merge(:skip_missing_check => true, force_parse: force_parse))
          end

          diffs = response.data(:diffs)
          unless args[:do_not_print]
            if diffs && !diffs.empty?
              print = process_semantic_diffs(diffs, method)
            else
              print = process_semantic_diffs(existing_diffs, method)
            end

            # if diffs is nil then indicate no diffs, otherwise render diffs in yaml
            OsUtil.print_info("No Diffs to be #{method}.") if response.data(:diffs).nil? || !print
          end

          nil
        end
      end
      
      def self.process_semantic_diffs(diffs, method)
        return if (diffs || {}).empty?
        print = false
        
        diffs.each {|diff| print = true unless diff[1].nil?}

        if print
          OsUtil.print_info("\nDiffs that were #{method}:")

          diffs.each { |v| diffs.delete(v[0]) if v[1].nil? }
          OsUtil.print(hash_to_yaml(diffs).gsub("---\n", ""))
        end
        
        print
      end

      class TerminateInstall < ::Exception
      end
    end
  end
end


