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
  class ServiceAndComponentInfo::TransformFrom
    class Info
      require_relative('info/service')
      require_relative('info/component')

      attr_reader :input_file_paths
      def initialize(content_dir, dtk_dsl_parse_helper)
        @content_dir            = content_dir
        @dtk_dsl_info_processor = dtk_dsl_parse_helper.info_processor(info_type)

        # dynamically computed
        @input_file_paths     = [] 
        @directory_file_paths = nil # this will be all paths in module
      end
      private :initialize

      def self.create(info_type, content_dir, dtk_dsl_parse_helper)
        case info_type
        when :service_info then Service.new(content_dir, dtk_dsl_parse_helper)
        when :component_info then Component.new(content_dir, dtk_dsl_parse_helper)
        else
          fail Error, "Unexpected info_type '#{info_type}'"
        end
      end

      private

      def add_content!(input_files_processor, path)
        @input_file_paths << path
        input_files_processor.add_content!(path, get_raw_content?(path))
      end

      def input_files_processor(type)
        @dtk_dsl_info_processor.indexed_input_files[type] || raise_missing_type_error(type)
      end      

      def module_refs_path
        matches = dsl_file_matches { |path| module_ref_input_files_processor.match?(path) }
        raise Error, "Unexpected that multiple module ref files" if matches.size > 1
        matches.first
      end

      def dsl_file_matches(&block)
        # TODO: maybe better to solve by restricting directory_file_paths to be least_nested_pos of 2
        matches = directory_file_paths.select { |path| block.call(path) }
        if matches.size > 1
          least_nested_pos = matches.map { |match| match.split('/').size }.min
          matches.reject! { |match| match.split('/').size != least_nested_pos }
        end
        matches
      end

      def module_ref_input_files_processor
        @module_ref_input_files_processor ||= input_files_processor(:module_refs)
      end

      def get_raw_content?(file_path)
        File.open(file_path).read if file_path and File.exists?(file_path)
      end

      def raise_missing_type_error(type)
        raise Error, "Unexpected that no indexed_input_files of type '#{type}'"
      end

      def directory_file_paths
        @directory_file_paths ||= Dir.glob("#{@content_dir}/**/*")
      end

      def get_raw_content?(file_path)
        File.open(file_path).read if file_path and File.exists?(file_path)
      end

    end
  end
end
