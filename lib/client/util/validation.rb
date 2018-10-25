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
module DTK::Client
  module Validation
    def self.validate_name(name)
      raise Error::Usage, "Name '#{name}' contains invalid characters! Valid characters are: #{valid_characters}" unless valid_name?(name)
      name
    end

    def self.process_comma_seperated_contexts(comma_seperated_contexts)
      if comma_seperated_contexts
        comma_seperated_contexts.split(',').map do |service_instance_name|
          service_instance_name.gsub!(' ', '')
          raise Error::Usage, "Name '#{name}' in context contains invalid characters! Valid characters are: #{valid_characters}" unless valid_name?(service_instance_name)
          service_instance_name
        end.reject(&:empty?)
      end
    end

    private

    def self.valid_name?(name)
      name.to_s.match(/\A[[a-z]\-\.\_\d]+\z/)
    end

    VALID_NAME_CHARACTERS = ['lowercase letters', 'numbers', '-', '_', '.']
    def self.valid_characters
      VALID_NAME_CHARACTERS.join("', '")
    end

  end
end
