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
  class LoadSource
    class ServiceInfo < self
      def fetch_and_cache_info
        fetch_remote
        merge_from_remote
        transform_from_service_info
      end

      def fetch_info
        fetch_remote
      end
      
      private
      
      def self.info_type
        :service_info
      end
      
      def transform_from_service_info
        info_processor.read_inputs_and_compute_outputs!
        
        # delete old files
        # Assumed that this is done before ComponentInfo.transform_from_service_info
        Operation::ClientModuleDir.delete_directory_content(target_repo_dir)
      end
      
    end
  end
end
