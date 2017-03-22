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
    class PullDtkn < self
      attr_reader :version, :module_ref, :target_repo_dir, :base_dsl_file_obj
      def initialize(catalog, module_ref, directory_path, version, base_dsl_file_obj)
        @catalog           = catalog
        @module_ref        = module_ref
        @directory_path    = directory_path
        @target_repo_dir   = directory_path || base_dsl_file_obj.parent_dir
        @version           = version # if nil wil be dynamically updated
        @base_dsl_file_obj = base_dsl_file_obj
        @parsed_module     = base_dsl_file_obj.parse_content(:common_module_summary)
        @print_helper      = Install::PrintHelper.new(:module_ref => module_ref, :source => :remote)
      end
      private :initialize

      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          module_ref          = args.required(:module_ref)
          base_dsl_file_obj   = args.required(:base_dsl_file_obj)
          version             = args[:version] || module_ref.version
          directory_path      = args[:directory_path]
          has_directory_param = args[:has_directory_param]
          skip_prompt         = args[:skip_prompt]
          force               = args[:force]

          if has_directory_param
            file_obj = base_dsl_file_obj.raise_error_if_no_content_flag(:module_ref)
          else
            file_obj = base_dsl_file_obj.raise_error_if_no_content
          end

          new('dtkn', module_ref, directory_path, version, file_obj).pull_dtkn(:skip_prompt => skip_prompt, :force => force)
        end
      end
      
      def pull_dtkn(opts = {})
        # TODO: DTK-2765: not sure if we need module to exist on server to do push-dtkn
        unless module_version_exists?(@module_ref, :type => :common_module)
          raise Error::Usage, "Module #{@module_ref.print_form} does not exist on server"
        end

        if ref_version = @version || module_ref.version
          raise Error::Usage, "You are not allowed to pull module version '#{ref_version}'!" unless ref_version.eql?('master')
        end

        error_msg = "To allow pull-dtkn to go through, invoke 'dtk push' to push the changes to server before invoking pull-dtkn again"
        GitRepo.modified_with_diff?(@target_repo_dir, { :error_msg => error_msg })

        query_string_hash = QueryStringHash.new(
          :module_name => @module_ref.module_name,
          :namespace   => @module_ref.namespace,
          :rsa_pub_key => SSHUtil.rsa_pub_key_content,
          :version?    => @version
        )
        remote_module_info = rest_get "#{BaseRoute}/remote_module_info", query_string_hash

        unless @version
          @version = remote_module_info.required(:version)
          @module_ref.version = @version
        end

        unless dependent_modules.empty?
          begin
            Install::DependentModules.install(@module_ref, dependent_modules, :skip_prompt => opts[:skip_prompt], :mode => 'pull')
            # Install::DependentModules.install(@module_ref, dependent_modules, :skip_prompt => false, :mode => 'pull')
          rescue Install::TerminateInstall
            @print_helper.print_terminated_pulling
            return nil
          end
        end

        @print_helper.print_continuation_pulling_base_module
        LoadSource.fetch_transform_and_merge(remote_module_info, self, :stage_and_commit_steps => true, :force => opts[:force])

        nil
      end

      private

      def dependent_modules
        @dependent_modules ||= compute_dependent_modules
      end

      def compute_dependent_modules
        base_component_module_found = false
        ret = (@parsed_module.val(:DependentModules) || []).map do |parsed_module_ref|
          dep_module_name = parsed_module_ref.req(:ModuleName)
          dep_namespace   = parsed_module_ref.req(:Namespace)
          dep_version     = parsed_module_ref.val(:ModuleVersion)
          if is_base_module = (dep_module_name == @module_ref.module_name)
            # This is for legacy modules
            base_component_module_found = true
          end
          Install::ModuleRef.new(:namespace => dep_namespace, :module_name => dep_module_name, :version => dep_version, :is_base_module => is_base_module)
        end
        unless base_component_module_found
          if module_version_exists?(@module_ref, :type => :component_module)
            ret << Install::ModuleRef.new(:namespace => @module_ref.namespace, :module_name => @module_ref.module_name, :version => @module_ref.version, :is_base_module => true)
          end
        end
        ret
      end

    end
  end
end


