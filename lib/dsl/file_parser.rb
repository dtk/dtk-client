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

require 'dtk_common_core'

module DTK::DSL
  class FileParser                   
    require_relative('file_parser/template')
    require_relative('file_parser/yaml_parser')
    require_relative('file_parser/input')
    require_relative('file_parser/output')

    # opts can have keys:
    #  :dsl_version
    def self.parse_content(parse_template_type, file_obj, opts = {})
      ret = Output.create(:output_type => :hash)
      return ret unless file_obj.content?

      input_hash = yaml_parse!(file_obj)
      dsl_version =  opts[:dsl_version] || dsl_version__raise_error_if_illegal(input_hash, file_obj)

      # parsing with respect to the parse_template_type
      parser_class = Template.template_class(parse_template_type, dsl_version)
      parser_class.new(input_hash, :file_obj => file_obj).parse
    end

    def self.yaml_parse!(file_obj)
      if file_obj.respond_to?(:yaml_parse_hash) 
        if ret = file_obj.yaml_parse_hash
          ret
        else
          file_obj.yaml_parse_hash = YamlParser.parse(file_obj)
        end
      else
        YamlParser.parse(file_obj)
      end
    end

    def self.file_ref_in_error(file_obj)
      (file_obj && file_obj.path?) ? " in file #{file_obj.path?}" : ''
    end
    
    private

    DSL_VERSION_KEY = 'dsl_version'
    def self.dsl_version__raise_error_if_illegal(input_hash, file_obj)
      if dsl_version = input_hash[DSL_VERSION_KEY]
        unless DSLVersion.legal?(dsl_version)
          raise Error::Usage, "Illegal DSL version '#{dsl_version}'#{file_ref_in_error(file_obj)}"
        end
        DSLVersion.new(dsl_version)
      else
        DSLVersion.default
      end
    end
  end
end

