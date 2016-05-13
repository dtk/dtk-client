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
    module RenderMixin
      def render_attributes_init!
        @semantic_datatype  = nil
        @skip_render       = false
        @render_type       = Render::Type::DEFAULT
      end
      private :render_attributes_init!

      def render_data(print_error_table = false)
        return nil if @skip_render
        return hash_part  unless ok?

        @print_error_table ||= print_error_table
        # if response is empty, response status is ok but no data is passed back
        if data.empty? or (data.is_a?(Array) ? data.first.nil? : data.nil?)
          @render_type = Render::Type::SIMPLE_LIST
          if data.kind_of?(Array)
            set_data('Message' => 'List is empty.')
          else #data.kind_of?(Hash)
            set_data('Status' => 'OK')
          end
        end

        render_opts = {
          :render_type       => @render_type,
          :semantic_datatype => @semantic_datatype,
          :print_error_table => @print_error_table
        }
        rendered_data = Render.render(data, render_opts)

        puts "\n" unless rendered_data
        rendered_data
      end
          
      def render_table(default_data_type=nil, use_default=false)
        unless ok?
          return self
        end
        unless data_type = (use_default ? default_data_type : (response_datatype || default_data_type))
          raise ::DTK::Client::Error, 'Server did not return datatype.'
        end

        @semantic_datatype = symbol_to_data_type_upcase(data_type)
        @render_type = Render::Type::TABLE
        self
      end

      def set_datatype(data_type)
        @semantic_datatype = symbol_to_data_type_upcase(data_type)
        self
      end

      private

      def response_datatype
        self['datatype'] && self['datatype'].to_sym
      end

      def hash_part
        keys.inject(Hash.new){|h,k|h.merge(k => self[k])}
      end
      
      def symbol_to_data_type_upcase(data_type)
        data_type.nil? ? nil : data_type.to_s.upcase
      end
    end
  end
end
