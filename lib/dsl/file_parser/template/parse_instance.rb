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
  class Template
    class ParseInstance < self
      # opts can have keys
      #   :file_obj
      def initialize(raw_input, opts = {})
        @input    = Input.create(raw_input)
        @file_obj = opts[:file_obj]
        @output   = @input.empty_output
      end
      
      def self.template_class(parse_template_type, dsl_version)
        Loader.template_class(parse_template_type, dsl_version)
      end
      
      # Main parse call; Each concrete class shoudl over write this
      def parse
        raise Error::NoMethodForConcreteClass.new(self.class)
      end
      
      private
      
      def input_hash
        @input_hash ||= @input.kind_of?(Input::Hash) ? @input : raise(Error, 'Unexpected that @input is not a hash')
      end

      def input_array
        @input_array = @input.kind_of?(Input::Array) ? @input : raise(Error, 'Unexpected that @input is not an array')
      end

      def parsing_error(error_msg = nil, &error_text)
        self.class.parsing_error(error_msg, &error_text)
      end
    end
  end
end; end

