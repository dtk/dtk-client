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
  class FileParser                   
    class Template
      require_relative('template/constant_class_mixin')
      require_relative('template/helper')
      require_relative('template/parse_instance')
      require_relative('template/parsing_error')
      require_relative('template/loader')

      def self.parsing_error(error_msg = nil, &error_text)
        ParsingError.new(:error_msg => error_msg, :file_obj => @file_obj, &error_text)
      end

    end
  end
end

