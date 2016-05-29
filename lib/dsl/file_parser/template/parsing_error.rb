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
module DTK::DSL
  class FileParser::Template
    class ParsingError < Error::Usage
      require_relative('parsing_error/subclasses')

      # opts can have keys
      #  :file_obj
      #  :qualified_key
      def initialize(error_msg, opts = {})
        @file_ref      = FileParser.file_ref_in_error(opts[:file_obj])
        @qualified_key = opts[:qualified_key]
        # TODO: later enhancment can use @qualified_key to find line numbers in yaml file
        key_ref = @qualified_key ? " under key '#{@qualified_key}'" : ''
        super("DTK parsing error#{key_ref}#{@file_ref}:\n  #{error_msg}")
      end
    end
  end
end


