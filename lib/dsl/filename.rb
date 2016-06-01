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
  # Contains information about what file names are
  class Filename
    def self.create_path_info
      DirectoryParser::PathInfo.new(regexp)
    end

    def self.matches?(file_path)
      DirectoryParser::PathInfo.matches?(file_path, regexp)
    end

    class BaseModule < self
      private
      # Purposely does not have ^ or $ so calling function can insert these depending on context
      def self.regexp
        /dtk\.module\.(yml|yaml)/
      end
    end

    class BaseService < self
      private
      # Purposely does not have ^ or $ so calling function can insert these depending on context
      def self.regexp
        /dtk\.service\.(yml|yaml)/
      end
    end
  end
end
