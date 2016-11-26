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
  class ServiceAndComponentInfo::TransformFrom::Info
    class Service < self
      def compute_output_files
        # Input assemblies and module_ref files
        assembly_file_paths.each { |path| add_content!(assembly_input_files_processor, path) }

        if module_refs_path = module_refs_path()
          add_content!(module_ref_input_files_processor, module_refs_path)
        end

        # compute top_level_dsl_file and return results
        dtk_dsl_info_processor.compute_output_file_array!
      end

      private

      def info_type
        :service_info
      end

      def assembly_file_paths
        directory_file_paths.select { |path| assembly_input_files_processor.match?(path) }
      end
      
      def module_refs_path
        matches = directory_file_paths.select { |path| module_ref_input_files_processor.match?(path) }
        raise Error, "Unexpected that multiple module ref files" if matches.size > 1
        matches.first
      end
      
      def assembly_input_files_processor 
        @assembly_input_files_processor = input_files_processor(:assemblies)
      end

      def module_ref_input_files_processor
        @module_ref_input_files_processor = input_files_processor(:module_refs)
      end

    end
  end
end
