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
  module Type                   
    class Loader
      include Singleton

      def initialize
        @loaded_types = {}
      end
      private :initialize

      def self.file_parser(file_type, version = nil)
        instance.file_parser(file_type, version)
      end

      def file_parser(file_type, version = nil)
        (@loaded_types[file_type]||{})[version] || load_file_parser(file_type, version)
      end
      BaseDirForFileTypes =  File.expand_path('../file_types', File.dirname(__FILE__))

      def load_file_parser(file_type, version = nil)
        raise Error.new("Illegal file type '#{file_type}'") unless TYPES.include?(file_type)
        #load base if no versions loaded already
        base_path = "#{BaseDirForFileTypes}/#{file_type}"
              
        version ||= default_version(file_type)
        require "#{base_path}/v#{version.to_s}/#{file_type}"
        
        base_class = FileParser.const_get(::DTK::Common::Aux.snake_to_camel_case(file_type.to_s))
        ret_class = base_class.const_get("V#{version.to_s}")
        input_hash_class = ret_class.const_get 'InputHash'
        (@loaded_types[file_type] ||= {})[version] = ret_class.new(input_hash_class)
      end
    end
  end
end; end
