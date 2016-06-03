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
  module ModuleRef
    MODULE_NAMESPACE_DELIMS = ['/', ':']

    # returns [namespace, module_name] or raises error
    def self.parse(input_string)
      split = split_by_delim(input_string)
      unless split.size == 2
        raise Error::Usage, "The term '#{input_string}' is an ill-formed module reference"
      end
      namespace, module_name = split
      [namespace, module_name]
    end

    private

    def self.split_by_delim(str)
      if matching_delim = MODULE_NAMESPACE_DELIMS.find { |delim| str =~ Regexp.new(delim) }
        str.split(matching_delim)
      else
        [str]
      end
    end
  end
end
