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
    class BaseDslFile
      include ::DTK::DSL

      attr_reader :path 
      # opts can have keys
      #  :dir_path
      #  :file_path
      def initialize(opts = {})
        @file_path = opts[:file_path]
        @dir_path  = opts[:dir_path]
        @content   = get_content?(@file_path)
      end
      private :initialize
      
      # This method finds the base dsl file if it exists returns a BaseDslFileobject
      # opts can have keys:
      #  :dir_path
      #  :file_path
      # Returns a BaseDslFile object even under error
      def self.find(opts = {})
        new(opts.merge(:file_path =>  opts[:file_path] || find_path?(opts)))
      end

      def content_or_raise_error
        @content || raise(Error::Usage, error_msg_no_content)
      end

      private

      def error_msg_no_content
        if @file_path
          "No DSL file found at '#{@file_path}'"
        else
          dir = @dir_path ? "specified directory '#{@dir_path}'" : "current directory '{OsUtil.current_dir}'"
          "Cannot find the base DTK DSL file in the #{dir} or ones nested under it"
        end
      end

      # This method finds the base dsl file if it exists and returns its path
      # opts can have keys:
      #  :dir_path
      def self.find_path?(opts = {})
        path_info = Parser::Filename::BaseModule.create_path_info
        directory_parser.most_nested_matching_file_path?(path_info, :current_dir => opts[:dir_path])
      end

      def get_content?(path)
        File.open(path).read if path and File.exists?(path)
      end

      def self.directory_parser
        @directory_parser ||= Parser::Directory::FileSystem.new
      end

    end
  end
end
