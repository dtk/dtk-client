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
      require_relative('template/loader')

      TYPES = [:base_module_top]

      # opts can have keys
      #   :file_obj
      def initialize(raw_input_hash, opts = {})
        @input_hash = InputHash.new(raw_input_hash)
        @file_obj   = opts[:file_obj]
      end

      def self.template_class(parse_template_type, dsl_version)
        Loader.template_class(parse_template_type, dsl_version)
      end

      def parse_input_hash
        raise Error::NoMethodForConcreteClass.new(self.class)
      end
    end
  end
end

