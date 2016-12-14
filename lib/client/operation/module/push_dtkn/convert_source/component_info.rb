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
  class Operation::Module::PushDtkn
    class ConvertSource
      class ComponentInfo < self
        # attr_reader :parsed_common_module

        def transform_info
          transform_to_component_info
        end
        
        private
        
        def self.info_type
          :component_info
        end
        
        def transform_to_component_info
          info_processor.read_inputs_and_compute_outputs!
          info_processor.file_path__content_array
        end

      end
    end
  end
end
