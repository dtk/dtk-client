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
    class Component < self
      def read_inputs_and_compute_outputs!
        # Input component dsl file and module_ref filedslpdslp
        if component_dsl_path = component_dsl_path()
          add_content!(component_dsl_input_files_processor, component_dsl_path)
        end

        if module_refs_path = module_refs_path()
          add_content!(module_ref_input_files_processor, module_refs_path)
        end

        # compute and cache outputs
        dtk_dsl_component_info_processor.compute_outputs!
      end

      private

      def info_type
        :component_info
      end

      def dtk_dsl_component_info_processor
        @dtk_dsl_info_processor
      end

      def component_dsl_path
        matches = directory_file_paths.select { |path| component_dsl_input_files_processor.match?(path) }
        raise Error, "Unexpected that there is not a unique component dsl file" if matches.size != 1
        matches.first
      end

      def component_dsl_input_files_processor
        @component_dsl_input_files_processor ||= input_files_processor(:component_dsl_file)
      end

    end
  end
end
