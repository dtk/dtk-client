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
require 'singleton'
module DTK::DSL; class FileParser
  class Template
    class Loader
      include Singleton
      def initialize
        @loaded_types = {}
      end
      private :initialize

      def self.parser(parse_template_type, version = nil)
        instance.parser(parse_template_type, version)
      end

      def parser(parse_template_type, version = nil)
        (@loaded_types[parse_template_type] || {})[version] || load_parser(parse_template_type, version)
      end
      BaseDirForFileTypes = File.dirname(__FILE__)

      def load_parser(parse_template_type, version = nil)
        raise Error.new("Illegal parse template type '#{parse_template_type}'") unless Template::TYPES.include?(parse_template_type)
        version ||= default_version(parse_template_type)
        require_relative("v#{version.to_s}/#{parse_template_type}")
        
        base_class = Template.const_get("V#{version.to_s}")
        ret_class = base_class.const_get(::DTK::Common::Aux.snake_to_camel_case(parse_template_type.to_s))
        input_hash_class = ret_class.const_get 'InputHash'
        (@loaded_types[parse_template_type] ||= {})[version] = ret_class.new(input_hash_class)
      end

      private

      def latest_dsl_version 
        @latest_dsl_version ||= Template::DSL_VERSIONS.sort.last
      end

      def default_version(_parse_template_type)
        latest_dsl_version
      end
    end
  end
end; end
