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
    class Common < self
      def initialize(remote_repo_url, target_repo_dir, parent)
        super(parent.catalog, parent.module_ref, parent.directory_path, parent.version)
        @remote_repo_url = remote_repo_url
        @target_repo_dir = target_repo_dir
      end
      private :initialize

      def self.install_from_catalog(remote_repo_url, target_repo_dir, parent)
        wrap_operation { new(remote_repo_url, target_repo_dir, parent).install_from_catalog }
      end

      private
      
      # TODO: will change this to actually do a fetch
      def fetch_remote(info_type)
        git_repo_args = {
          :info_type     => info_type,
          :repo_dir      => @target_repo_dir,
          :add_remote    => @remote_repo_url,
          :remote_branch => git_repo_remote_branch
        }
        Operation::ClientModuleDir::GitRepo.pull_from_dtkn(git_repo_args)
      end

    end
  end
end
