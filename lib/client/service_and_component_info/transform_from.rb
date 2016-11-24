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
  module ServiceAndComponentInfo
    class TransformFrom
      require_relative('transform_from/service_info')
      #require_relative('transform_from/component_info')

      def initialize(content_dir, module_ref, version)
        @content_dir  = content_dir
        @module_ref   = module_ref
        @version      = version
        @parse_helper = ret_parse_helper(module_ref, version)

        # dynamically set
        @directory_file_paths = nil
      end

      private

      attr_reader :parse_helper

      def ret_parse_helper(module_ref, version)
        parse_helper_class(info_type).new(module_ref.namespace, module_ref.module_name, version)
      end

      def parse_helper_class(info_type)
        case info_type
        when :service_info
          parse_helper_base_class::ServiceInfo
        when :component_info
          parse_helper_base_class::ComponentInfo
        else
          raise Error, "Illegal info_type '#{info_type}'"
        end
      end

      def parse_helper_base_class
        ::DTK::DSL::ServiceAndComponentInfo::TransformFrom
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

      # deperecate below
      def input_files(type)
        @parse_helper.indexed_input_files[type] || raise_missing_type_error(type)
      end      

    end
  end
end
