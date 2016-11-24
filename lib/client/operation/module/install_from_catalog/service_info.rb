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
        merge_from_remote
        transform_to_dtk_client_form
        stage_and_commit("Added service info")
        nil
      end

      private

      def self.info_type
        :service_info
      end

      def transform_to_dtk_client_form
        output_files = ServiceAndComponentInfo::TransformFrom::ServiceInfo.new(@target_repo_dir, @module_ref, @version).compute_output_files
        # delete old files
        Operation::ClientModuleDir.delete_directory_content(@target_repo_dir)

        output_files.each do |output_file|
          Operation::ClientModuleDir.create_file_with_content("#{@target_repo_dir}/#{output_file.path}", output_file.text_content)
        end
      end

    end
  end
end
