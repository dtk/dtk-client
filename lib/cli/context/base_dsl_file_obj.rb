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

      BASE_DSL_MAPPINGS = {
        :module => ::DTK::DSL::Filename::BaseModule,
        :service => ::DTK::DSL::Filename::BaseService
      }

      attr_accessor :base_dsl_type, :yaml_parse_hash
      # opts can have keys
      #  :dir_path
      #  :file_path
      def initialize(opts = {})
        base_dsl_type, path = find_type_and_path?(opts)
        @base_dsl_type = base_dsl_type
        @dir_path      = opts[:dir_path]
        super(::DTK::DSL::DirectoryParser::FileSystem.new, :path => path)  

        # below computed on demand
        @yaml_parse_hash = nil
      end

      def hash_content?
        ::DTK::DSL::FileParser.yaml_parse!(self) if exists?
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
      #  :file_path
      # returns nil or [base_dsl_type, path]
      def find_type_and_path?(opts = {})
        ret = nil
        if path = opts[:file_path]
          BASE_DSL_MAPPINGS.each do | dsl_type, filename_class|
            if filename_class.matches?(path)
              return [dsl_type, path]
            end
          end
        else
          BASE_DSL_MAPPINGS.each do | dsl_type, filename_class|
            path_info = filename_class.create_path_info
            if path = directory_parser.most_nested_matching_file_path?(path_info, :current_dir => opts[:dir_path])
              return [dsl_type, path]
            end
          end
        end
        ret
      end

      def directory_parser
        @@directory_parser ||= ::DTK::DSL::DirectoryParser::FileSystem.new
      end

    end
  end
end
