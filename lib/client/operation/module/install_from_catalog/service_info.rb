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
    class ServiceInfo < Base
      def install_from_catalog
        fetch_remote

        # TODO: might switch to using a transform merge rather than merging and then deleting and re-commiting
        merge_from_remote
        module_content_hash = ContentGenerator.new(@target_repo_dir, @module_ref, @version).generate_module_content
        # delete old files
        Operation::ClientModuleDir.delete_directory_content(@target_repo_dir)
        # generate dtk.module.yaml file from parsed assemblies and module_refs
        Operation::ClientModuleDir.create_file_with_content("#{@target_repo_dir}/dtk.module.yaml", self.class.hash_to_yaml(module_content_hash))
        nil
      end

      private

      def self.info_type
        :service_info
      end

    end
  end
end
