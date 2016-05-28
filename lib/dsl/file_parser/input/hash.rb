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
module DTK::DSL; class FileParser
  class Input
    class Hash < ::Hash
      def initialize(hash = nil)
        super()
        replace(reify(hash)) if hash
      end

      def [](index)
        super(internal_key_form(index))
      end
      
      def only_has_keys?(*only_has_keys)
        (keys - only_has_keys.map{ |k| internal_key_form(k) }).empty?
      end

      def reify(obj)
        if obj.kind_of?(self.class)
          obj
        elsif obj.kind_of?(::Hash)
          obj.inject(self.class.new) { |h, (k, v)| h.merge(k => reify(v)) }
        elsif obj.kind_of?(::Array)
          Input::Array.new(obj)
        else
          obj
        end
      end

      private

      def internal_key_form(key)
        key.to_s
      end
    end
  end
end; end

