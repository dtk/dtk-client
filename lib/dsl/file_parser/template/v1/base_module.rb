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
class DTK::DSL::FileParser::Template
  module V1
    class BaseModule < ParseInstance
      module Constant
        module Variations
        end
        extend ClassMixin::Constant

        Module = 'module'
        Variations::Module = ['module', 'module_name'] 

        DependentModules = 'dependent_modules'

      end

      def parse
        module_ref = constant_matches(input_hash, :Module)
        parsed_module_ref = ModuleRef.parse(module_ref, Constant::Module)
        @output.merge!(:namespace => parsed_module_ref.namespace, :module_name => parsed_module_ref.module_name)
      end
    end
  end
end
