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
    class OutputHash < ::DTK::Common::SimpleHashObject
      def merge_non_empty!(hash)
        hash.each{|k,v| merge!(k => v) unless v.nil? or v.empty?}
        self
      end
      
      def +(output_obj)
        if output_obj.kind_of?(OutputArray)
          OutputArray.new(self) + output_obj
        elsif output_obj.kind_of?(OutputHash)
          merge(output_obj)
        elsif output_obj.nil?
          self
        else
          raise Error.new("Unexpected object type (#{output_obj.class})")
        end
      end
    end
  end
end
