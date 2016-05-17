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

      attr_reader :path, :content
      def initialize(path)
        @path    = path
        @content = get_content?(path)
      end
      private :initialize

      # This method finds the base dsl file if it exists returns a BaseDslFileobject
      # opts can have keys:
      #   :path
      def self.find?(opts = {})
        if path = opts[:path] || find_path?
          new(path)
        end
      end

      private

      # This method finds the base dsl file if it exists and returns its path
      def self.find_path?
        path_info = Parser::Filename::BaseModule.create_path_info
        # TODO: stub
current_dir = File.expand_path('../../../examples/simple/test', File.dirname(__FILE__))
opts = { current_dir: current_dir }
ret =  directory_parser.most_nested_matching_file_path?(path_info, opts)
pp(current_dir: current_dir, most_nested_matching_file: ret)
ret
      end

      def get_content?(path)
        File.open(path).read if File.exists?(path)
      end

      def self.directory_parser
        @directory_parser ||= Parser::Directory::FileSystem.new
      end

    end
  end
end
