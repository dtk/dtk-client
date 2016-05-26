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
    class OutputArray < ::Array
      def <<(hash_el)
        bad_keys = hash_el.keys - self.class.keys_for_row
        unless bad_keys.empty?
          raise Error.new("Illegal keys being inserted in OutputArray (#{bad_keys.join(',')})")
        end
        super
      end
      
      def +(output_obj)
        if output_obj.kind_of?(OutputArray)
          super
        elsif output_obj.kind_of?(OutputHash)
          super(OutputArray.new(OutputHash))
        elsif output_obj.nil?
          self
        else
          raise Error.new("Unexpected object type (#{output_obj.class})")
        end
      end
      
      #can be overwritten
      def self.has_required_keys?(hash_el)
        (keys_for_row - hash_el.keys?).nil?
      end
    end
  end
end
