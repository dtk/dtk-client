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
  class ServiceAndComponentInfo::TransformTo::Info
    class Service < self
      def read_inputs_and_compute_outputs!
        # Input assemblies and module_ref file
        module_file_paths.each { |path| add_content!(module_input_files_processor, path) }

        # compute and cache outputs
        dtk_dsl_service_info_processor.compute_outputs!
      end

      private

      def info_type
        :service_info
      end

      def dtk_dsl_service_info_processor
        @dtk_dsl_info_processor
      end

      def module_file_paths
        directory_file_paths.select { |path| module_input_files_processor.match?(path) }
      end
      
      def module_input_files_processor
        @module_input_files_processor ||= input_files_processor(:module)
      end

    end
  end
end
