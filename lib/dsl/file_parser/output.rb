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
    class Output
      # opts can have keys
      #  :output_type
      #  :input
      def self.create(opts = {})
        if output_type = opts[:output_type]
          create_from_output_type(output_type)
        elsif input = opts[:input]
          create_from_input(input)
        else 
          raise Error, "opts must have one of the keys :output_type or :input"
        end
      end

      private

      def self.create_from_output_type(output_type)
        case output_type
          when :hash then ::Hash.new
          when :array then ::Array.new
          when :string then ::String.new
          else raise Error, "Unexpected output_type '#{output_type}'"
        end
      end

      def self.create_from_input(input)
        if input.kind_of?(::Hash) then ::Hash.new
        elsif input.kind_of?(::Array) then ::Array.new
        elsif input.kind_of?(::String) then ::String.new
        else raise Error, "Unexpected input type '#{input.class}'"
        end
      end
    end
  end
end
