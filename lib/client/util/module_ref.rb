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
  class ModuleRef

    attr_reader :namespace, :module_name

    def initialize(namespace, module_name)
      @namespace   = namespace
      @module_name = module_name
    end

    MODULE_NAMESPACE_DELIMS = ['/', ':']
    PRINT_FORM_DELIM = ':'

    # returns [namespace, module_name] or raises error
    def self.reify(input_string_or_module_ref_obj)
      return input_string_or_module_ref_obj if input_string_or_module_ref_obj.kind_of?(self)

      input_string = input_string_or_module_ref_obj
      split = split_by_delim(input_string)
      raise(Error::Usage, "The term '#{input_string}' is an ill-formed module reference") unless split.size == 2
      namespace, module_name = split
      new(namespace, module_name)
    end

    def print_form
      "#{@namespace}#{PRINT_FORM_DELIM}#{@module_name}"
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
