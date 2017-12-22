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
          module_ref    = args.required(:module_ref)
          method        = args[:method] || "pushed"
          allow_version = args[:allow_version]

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


