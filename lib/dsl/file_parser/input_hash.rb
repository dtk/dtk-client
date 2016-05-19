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
    class InputHash < ::Hash
      #to provide autovification and use of symbol indexes
      def initialize(hash = nil)
        super()
        return unless hash
        replace_el = hash.inject({}) do |h,(k,v)|
          processed_v = (v.kind_of?(::Hash) ? self.class.new(v) : v)
          h.merge(k =>  processed_v)
        end
        replace(replace_el)
      end
      
      def [](index)
        val = super(internal_key_form(index)) || {}
        (val.kind_of?(::Hash) ? self.class.new(val) : val)
      end
      def only_has_keys?(*only_has_keys)
        (keys - only_has_keys.map{ |k| internal_key_form(k) }).empty?
      end
      private
      def internal_key_form(key)
        key.to_s
      end
    end
  end
end
