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
# This is wrapper for holding rest response information as well as
# passing selection of ViewProcessor from Thor selection to render view
# selection
module DTK::Client
  class Response
    module RenderHelperMixin
      def render_attributes_init!
        @semantic_datatype = nil
        @skip_render       = false
        @render_type       = Render::Type::DEFAULT
      end
      private :render_attributes_init!

      def render_data(print_error_table = false)
        return if @skip_render

        @print_error_table ||= print_error_table

        render_opts = {
          :render_type       => @render_type,
          :semantic_datatype => @semantic_datatype,
          :print_error_table => @print_error_table
        }
        Render.render(data, render_opts)
      end
          
      def set_render_as_table!(semantic_datatype = nil)
        return self unless ok?

        unless semantic_datatype ||= semantic_datatype_in_payload
          error_hash = {
            'message'   => 'Server did not return table datatype',
            'on_client' => false
          }
          return ErrorResponse::Internal.new(error_hash)
        end
        @semantic_datatype = normalize_semantic_datatype(semantic_datatype)
        @render_type = Render::Type::TABLE
        self
      end

      private

      def semantic_datatype_in_payload
        self['datatype'] && self['datatype'].to_sym
      end

      def hash_part
        keys.inject(Hash.new){|h,k|h.merge(k => self[k])}
      end

      def normalize_semantic_datatype(semantic_datatype)
        semantic_datatype && semantic_datatype.to_sym
      end
    end
  end
end
