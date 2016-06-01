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
  class CLI::Context
    class BaseDslFileObj < ::DTK::DSL::FileObj
      attr_accessor :yaml_parse_hash
      # opts can have keys
      #  :dir_path
      #  :file_path
      def initialize(opts = {})
        super(:path =>  opts[:file_path] || find_path?(opts))
        @dir_path  = opts[:dir_path]
        # below computed on demand
        @yaml_parse_hash = nil
      end

      private

      def file_path_type
        'Base DSL file'
      end

      def dir_ref
        @dir_path ? "specified directory '#{@dir_path}'" : "current directory '#{OsUtil.current_dir}'"
      end

      # This method finds the base dsl file if it exists and returns its path
      # opts can have keys:
      #  :dir_path
      def self.find_path?(opts = {})
        path_info = ::DTK::DSL::Filename::BaseModule.create_path_info
        directory_parser.most_nested_matching_file_path?(path_info, :current_dir => opts[:dir_path])
      end
      def find_path?(opts = {})
        self.class.find_path?(opts)
      end

      def self.directory_parser
        @directory_parser ||= ::DTK::DSL::DirectoryParser::FileSystem.new
      end

    end
  end
end
