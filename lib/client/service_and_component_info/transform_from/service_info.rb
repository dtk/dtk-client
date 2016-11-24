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
  class ServiceAndComponentInfo::TransformFrom
    class ServiceInfo < self
      def compute_output_files
        assembly_input_files =  @parse_helper.indexed_input_files[:assemblies] || raise_missing_type_error(:assemblies)
        assembly_file_paths.each do |path|
          assembly_input_files.add_content!(path, get_raw_content?(path)) 
        end
        
        if module_refs_path = module_refs_path()
          module_refs_files = @parse_helper.indexed_input_files[:module_refs] || raise_missing_type_error(:module_refs)
          module_refs_files.add_content!(module_refs_path, get_raw_content?(module_refs_path))
        end

        @parse_helper.compute_outputs!
        @parse_helper.output_file_array(:top_level_dsl_file)
      end
      private

      def info_type
        :service_info
      end

      def assembly_input_files 
        @assembly_input_files ||= input_files(:assemblies)
      end
      
      def module_ref_input_files
        @module_ref_input_files ||= input_files(:module_refs)
      end
      
      def assembly_file_paths
        directory_file_paths.select { |path| assembly_input_files.match?(path) }
      end
      
      def module_refs_path
        matches = directory_file_paths.select { |path| module_ref_input_files.match?(path) }
        raise Error, "Unexpected that multiple module ref files" if matches.size > 1
        matches.first
      end
      
    end
  end
end
