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
module DTK::DSL; class FileParser::Template
  class V1
    class BaseModuleTop < self
      module Constant
        module Variations
        end
        extend ClassMixin::Constant

        Module = 'module'
        Variations::Module = ['module', 'module_name'] 
      end

      def initialize(*args)
        super(:hash, *args)
      end

      def parse_input_hash
        unless module_ref = Constant.matches?(input_hash, :Module)
          raise parsing_error { missing_top_level_key(Constant::Module) }
        end
        parse_module_ref(module_ref)
     pp   @output
@output
      end

      private

      MODULE_NAMESPACE_DELIMS = ['/', ':']
      def parse_module_ref(module_ref)
        unless module_ref.kind_of?(String)
          raise parsing_error { wrong_object_type(Constant::Module, module_ref, String) }
        end
        split = split_by_delim(module_ref, MODULE_NAMESPACE_DELIMS)
        unless split.size == 2
          raise parsing_error("The term '#{module_ref}' is an ill-formed module reference")
        end
        @output.merge!(:namespace => split[0], :module_name => split[1])
      end

      def split_by_delim(str, delims)
        if matching_delim = delims.find { |delim| str =~ Regexp.new(delim) }
          str.split(matching_delim)
        else
          [str]
        end
      end

    end
  end
end; end
