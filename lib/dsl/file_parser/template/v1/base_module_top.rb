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
module DTK::DSL; class FileParser 
  class Template::V1
    class BaseModuleTop < self
      module Constant
        module Variations
        end
        extend ParsingingHelper::ClassMixin
        Module = 'module'
        Variations::Module = ['module', 'module_name'] 
      end

      def parse_input_hash
        ret = OutputArray.new
        unless module_ref = Constant.matches?(input_hash, :Module)
          raise parsing_error { missing_top_level_key(:module) }
        end
        ret
      end
    end
  end
end; end
