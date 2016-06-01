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
  class DirectoryParser    
    class PathInfo
      attr_reader :regexp, :depth, :base_dir
      # opts can have keys
      #  :depth - used for pruning when a git directory
      def initialize(regexp_or_string, opts = {})
        @regexp   = ret_regexp(regexp_or_string)
        @depth    = opts[:depth]
        @base_dir = opts[:base_dir]
      end

      def matches?(file_path)
        self.class.matches?(file_path, @regexp)
      end
      def self.matches?(file_path, regexp)
        # extra check to see if regep is just for file part or has '/' seperators
        if '/' =~ regexp
          file_path.split(OsUtil.delim).last =~ Regexp.new("^#{regexp.source}$")
        else
          file_path =~ Regexp.new("#{regexp.source}$")
        end
      end

      private

      def ret_regexp(regexp_or_string)
        if regexp_or_string.kind_of?(String)
          Regexp.new(regexp_or_string)
        elsif regexp_or_string.kind_of?(Regexp)
          regexp_or_string
        else
          raise Error, "Unexpected class '#{regexp_or_string.class}'"
        end
      end
    end
  end
end
