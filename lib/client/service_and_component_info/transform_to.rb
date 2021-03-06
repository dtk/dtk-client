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
    # TODO: DTK-2765: methods use wen pushing to dtkn that transform to component and info form
    # This wil call functions that parse in :DTK::DSL::ServiceAndComponentInfo::TransformTO
    class TransformTo
      require_relative('transform_to/info')

      def initialize(content_dir, module_ref, version, parsed_common_module)
        @content_dir          = content_dir
        @module_ref           = module_ref
        @version              = version
        @dtk_dsl_parse_helper = dtk_dsl_transform_class.new(module_ref.namespace, module_ref.module_name, version)
        @parsed_common_module = parsed_common_module
      end

      def info_processor(info_type)
        Info.create(info_type, @content_dir, @dtk_dsl_parse_helper, @parsed_common_module)
      end

      def output_path_text_pairs
        @dtk_dsl_parse_helper.output_path_text_pairs
      end

      private

      def dtk_dsl_transform_class
        ::DTK::DSL::ServiceAndComponentInfo::TransformTo
      end
    end
  end
end

