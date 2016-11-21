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
  class Operation::Module::InstallFromCatalog
    class ServiceInfo < self
      def initialize(remote_repo_url, target_repo_dir, parent)
        super(parent.catalog, parent.module_ref, parent.directory_path, parent.version)
        @remote_repo_url = remote_repo_url
        @target_repo_dir = target_repo_dir
      end
      private :initialize

      def self.install_from_catalog(remote_repo_url, target_repo_dir, parent)
        wrap_operation { new(remote_repo_url, target_repo_dir, parent).install_from_catalog }
      end

      def install_from_catalog
        git_repo_args = {
          :repo_dir      => @target_repo_dir,
          :repo_url      => @remote_repo_url,
          :remote_branch => git_repo_remote_branch
        }

        # TODO: convert to use fetch_transform_merge
        Operation::ClientModuleDir::GitRepo.create_add_remote_and_pull(git_repo_args)

        module_content_hash = ContentGenerator.new(@target_repo_dir, @module_ref, @version).generate_module_content

        # delete old files
        Operation::ClientModuleDir.delete_directory_content(@target_repo_dir)

        # generate dtk.module.yaml file from parsed assemblies and module_refs
        Operation::ClientModuleDir.create_file_with_content("#{@target_repo_dir}/dtk.module.yaml", self.class.hash_to_yaml(module_content_hash))
        nil
      end

    end
  end
end
