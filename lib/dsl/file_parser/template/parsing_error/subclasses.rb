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
class DTK::DSL::FileParser; class Template                   
  class ParsingError
    class MissingKeyValue < self
      def initialize(key, opts = {})
        error_msg = "Missing value for key '#{key}'"
        super(error_msg, opts)
      end
    end
    
    class WrongObjectType < self
      def initialize(obj, correct_ruby_type, opts = {})
        error_msg = "The key's value should be of type #{correct_ruby_type}, but has type #{input_class_string(obj)}"
        super(error_msg, opts)
      end
      
      private
      
      def input_class_string(obj)
        # The special casing on Input::Hash is not needed since end with Hash and Array, but this makes it more robust
        # if change the Input subclasses
        klass = 
          if obj.kind_of?(Input::Hash) 
            ::Hash 
          elsif obj.kind_of?(Input::Array)
            ::Array
          else
            obj.class
          end
        # demodularize
        klass.to_s.split('::').last
      end
    end
  end
end; end


