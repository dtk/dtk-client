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
require 'yaml'
require 'dtk_common_core'

module DTK::DSL
  class FileParser                   
    require_relative('file_parser/template')
    require_relative('file_parser/input_hash')
    require_relative('file_parser/output_array')
    require_relative('file_parser/output_hash')
    
    # opts can have keys:
    #  :version
    def self.parse_content(parse_template_type, file_obj, opts = {})
      ret = OutputArray.new
      return ret unless file_obj.content?

      # YAML parsing
      raw_input_hash_content = convert_yaml_content_to_hash(file_obj)
      parser_class = Template.template_class(parse_template_type, opts[:version])
      # parsing with respect to the parse_template_type
      parser_class.new(raw_input_hash_content, :file_obj => file_obj).parse_input_hash
    end
    
    private
    
    def self.convert_yaml_content_to_hash(file_obj)
      begin
        ::YAML.load(file_obj.content)
      rescue Exception => e
        raise Error::Usage::InFile, "YAML parsing error #{e.to_s} in file", :file_path => file_obj.path?
      end
    end
  end
end

