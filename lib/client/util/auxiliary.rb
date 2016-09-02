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

module DTK::Client
  module Auxiliary
    def snake_to_camel_case(snake_form)
      snake_form.to_s.gsub('-','_').to_s.split('_').map{|t|t.capitalize}.join('')
    end
    
    def snake_form(command_class, seperator='_')
      command_class.to_s.gsub(/^.*::/, '').gsub(/Command$/,'').scan(/[A-Z][a-z]+/).map{|w|w.downcase}.join(seperator)
    end

    def hash_to_yaml(hash_content)
      YAML.dump(hash_content)
    end
  end
end
