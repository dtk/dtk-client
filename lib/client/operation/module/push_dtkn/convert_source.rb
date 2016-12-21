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
module DTK::Client; class Operation::Module
  class PushDtkn
    class ConvertSource
      require_relative('convert_source/service_info')
      require_relative('convert_source/component_info')

      def initialize(transform_helper, info_type, remote_repo_url, parent)
        @info_processor   = transform_helper.info_processor(info_type)
        @info_type        = info_type
        @remote_repo_url  = remote_repo_url
        @target_repo_dir  = parent.target_repo_dir
        @version          = parent.version
      end
      private :initialize

      def self.transform_and_commit(remote_module_info, parent)
        target_repo_dir      = parent.target_repo_dir
        parsed_common_module = parent.base_dsl_file_obj.parse_content(:common_module)

        if service_info = remote_module_info.data(:service_info)
          transform_service_info(target_repo_dir, parent, service_info, parsed_common_module)
        end

        if component_info = remote_module_info.data(:component_info)
          transform_component_info(target_repo_dir, parent, component_info, parsed_common_module)
        end
      end

      def self.transform_info(transform_helper, remote_repo_url, parent)
        new(transform_helper, info_type, remote_repo_url, parent).transform_info
      end

      def self.transform_service_info(target_repo_dir, parent, service_info, parsed_common_module)
        transform_helper = ServiceAndComponentInfo::TransformTo.new(target_repo_dir, parent.module_ref, parent.version, parsed_common_module)
        service_file_path__content_array = ServiceInfo.transform_info(transform_helper, service_info['remote_repo_url'], parent)

        repo = checkout_branch__return_repo(target_repo_dir, "remotes/dtkn/master").data(:repo)
        FileUtils.mkdir_p("#{target_repo_dir}/assemblies") unless File.exists?("#{target_repo_dir}/assemblies")

        args = [transform_helper, ServiceInfo.info_type, service_info['remote_repo_url'], parent]
        service_file_path__content_array.each { |file| Operation::ClientModuleDir.create_file_with_content("#{service_file_path(target_repo_dir, file, *args)}", file[:content]) }

        commit_and_push_to_remote(repo, target_repo_dir, "master", "dtkn")
      end

      def self.transform_component_info(target_repo_dir, parent, component_info, parsed_common_module)
        transform_helper = ServiceAndComponentInfo::TransformTo.new(target_repo_dir, parent.module_ref, parent.version, parsed_common_module)
        component_file_path__content_array = ComponentInfo.transform_info(transform_helper, component_info['remote_repo_url'], parent)

        repo = checkout_branch__return_repo(target_repo_dir, "remotes/dtkn-component-info/master").data(:repo)
        component_file_path__content_array.each { |file| Operation::ClientModuleDir.create_file_with_content("#{file_path(target_repo_dir, file)}", file[:content]) }

        commit_and_push_to_remote(repo, target_repo_dir, "master", "dtkn-component-info")
      end
      
      private

      attr_reader :info_processor, :target_repo_dir, :parent

      def self.write_output_path_text_pairs(transform_helper, target_repo_dir, info_types_processed)
      end

      def self.file_path(target_repo_dir, file)
        file[:full_path] ? file[:path] : "#{target_repo_dir}/#{file[:path]}"
      end

      def self.service_file_path(target_repo_dir, file, *args)
        @new_service_info  ||= ServiceInfo.new(*args)
        @legacy_assemblies ||= @new_service_info.legacy_assemblies?

        if @legacy_assemblies && !file[:path].include?('module_refs.yaml')
          convert_to_legacy_assebmly(target_repo_dir, file)
        else
          file_path(target_repo_dir, file)
        end
      end

      def self.convert_to_legacy_assebmly(target_repo_dir, file)
        return file[:path] if file[:full_path]

        file_path     = file[:path]
        file_name     = file_path.split('/').last
        assembly_name = file_name.split('.').first

        "#{target_repo_dir}/assemblies/#{assembly_name}/assembly.yaml"
      end

      def self.checkout_branch__return_repo(target_repo_dir, branch)
        git_repo_args = {
          :repo_dir     => target_repo_dir,
          :local_branch => branch
        }
        git_repo_operation.checkout_branch__return_repo(git_repo_args)
      end

      def self.commit_and_push_to_remote(repo, target_repo_dir, branch, remote)
        repo.stage_and_commit("Add auto-generated files from push-dtkn")
        repo.push_from_cached_branch(remote, branch, { :force => true })
        repo.checkout('master')
      end

      def self.stage_and_commit(target_repo_dir, commit_msg = nil)
        git_repo_args = {
          :repo_dir          => target_repo_dir,
          :commit_msg        => commit_msg,
          :local_branch_type => :dtkn
        }
        git_repo_operation.stage_and_commit(git_repo_args)
      end

      def self.commit_msg(info_types_processed)
        msg = "Added "
        count = 0
        types = info_types_processed #info
        if types.include?(ServiceInfo.info_type)
          msg << 'service '
          count +=1
        end
        if types.include?(ComponentInfo.info_type)
          msg << 'and ' if count > 0
          msg << 'component'
          count +=1
        end
        msg << 'info'
        msg
      end

      def self.git_repo_operation
        Operation::ClientModuleDir::GitRepo
      end
      def git_repo_operation
        self.class.git_repo_operation
      end

    end
  end
end; end
