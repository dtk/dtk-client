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
module DTK::DSL
  class FileParser                   
    module YamlParser
      # Returns hash if succsefully parse; otehrwise raises error
      def self.parse(file_obj)
        begin
          ::YAML.load(file_obj.content)
        rescue Exception => e
          raise Error::Usage, yaml_parsing_error_msg(e, file_obj)
        end
      end

      private

      def self.yaml_parsing_error_msg(e, file_obj)
        file_ref = FileParser.file_ref_in_error(file_obj)
        yaml_err_msg = e.message.gsub(/\(<unknown>\): /,'').capitalize 
        "YAML parsing error#{file_ref}:\n#{yaml_err_msg}"
      end
    end
  end
end
