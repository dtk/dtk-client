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

module DTK::Client::CLI
  class DirectoryParser < ::DTK::DSL::DirectoryParser
    require_relative('directory_parser/file_system')
    # file_types - a single or array of FileObj objects
    # opts can have keys
    #   :file_path - string
    #   :dir_path - string
    # Returns FileObj that matches a file_typeo bject that matches a file_type in file_types
    #   or returns nil if no match found
    def self.matching_file_obj?(file_types, opts = {})
      adapter.matching_file_obj?(file_types, opts)
    end

    def self.adapter
      @adapter ||= FileSystem.new
    end
  end
end

