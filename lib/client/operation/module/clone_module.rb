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
    class CloneModule < self
      attr_reader :target_repo_dir, :module_ref
      def initialize(module_ref, target_directory)
        @module_ref      = module_ref
        @target_repo_dir = target_directory || ClientModuleDir.ret_path_with_current_dir(module_ref.module_name)
      end
      private :initialize

      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          module_ref       = args.required(:module_ref)
          target_directory = args[:target_directory]
          new(module_ref, target_directory).clone_module
        end
      end

      def clone_module
        unless module_info = module_version_exists?(@module_ref, :type => :common_module, :remote_info => false, :rsa_pub_key => SSHUtil.rsa_pub_key_content)
          raise Error::Usage, "DTK module '#{@module_ref.pretty_print}' does not exist on the DTK Server."
        end

        # This handles state where a depenent module is just created as a component module and consequently we tell server
        # to create the common_module tied to it
        unless module_info.data(:repo)
          module_info = create_module_repo_from_component_info 
        end

        branch    = module_info.required(:branch, :name)
        repo_url  = module_info.required(:repo, :url)
        repo_name = module_info.required(:repo, :name)

        clone_args = {
          :module_type => :common_module,
          :repo_url    => module_info.required(:repo, :url),
          :branch      => module_info.required(:branch, :name),
          :module_name => @module_ref.module_name,
          :repo_dir    => @target_repo_dir
        }

        ret = ClientModuleDir::GitRepo.clone_module_repo(clone_args)

        if module_info.data(:component_info) || module_info.data(:service_info)
          LoadSource.fetch_from_remote(module_info, self)
        end

        # OsUtil.print_info("DTK module '#{@module_ref.pretty_print}' has been successfully cloned into '#{ret.required(:target_repo_dir)}'")
        target_repo_dir = ret.required(:target_repo_dir)
        pull_service_info = check_if_pull_needed
        {
          target_repo_dir: target_repo_dir,
          pull_service_info: pull_service_info
        }
      end

      def version
        @module_ref.version
      end

      private

      def create_module_repo_from_component_info
        rest_post("#{BaseRoute}/create_repo_from_component_info", module_ref_post_body)
      end

      def module_ref_post_body
        self.class.module_ref_post_body(@module_ref)
      end

      def check_if_pull_needed
        query_string_hash = QueryStringHash.new(
          :module_name => @module_ref.module_name,
          :namespace   => @module_ref.namespace,
          :rsa_pub_key => SSHUtil.rsa_pub_key_content,
          :version     => version||'master'
        )

        begin
          remote_module_info = rest_get "#{BaseRoute}/remote_module_info", query_string_hash
        rescue DTK::Client::Error::ServerNotOkResponse => e
          # ignore if remote does not exist
        end

        if remote_module_info && remote_module_info.data(:service_info)
          !module_version_exists?(@module_ref, :type => :service_module)
        end
      end

    end
  end
end


