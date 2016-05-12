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
      def render_data(print_error_table=false)
        unless @skip_render
          if ok?

            @print_error_table ||= print_error_table

            # if response is empty, response status is ok but no data is passed back
            if data.empty? or (data.is_a?(Array) ? data.first.nil? : data.nil?)
              @render_view = RenderView::SIMPLE_LIST
              if data.kind_of?(Array)
                set_data('Message' => "List is empty.")
              else #data.kind_of?(Hash)
                set_data('Status' => 'OK')
              end
            end

            # sending raw data from response
            rendered_data = ViewProcessor.render(@command_class, data, @render_view, @render_data_type, nil, @print_error_table)

            puts "\n" unless rendered_data
            return rendered_data
          else
            hash_part
          end
        end
      end
      
      def render_table(default_data_type=nil, use_default=false)
        unless ok?
          return self
        end
        unless data_type = (use_default ? default_data_type : (response_datatype || default_data_type))
          raise DTK::Client::DtkError, "Server did not return datatype."
        end

        @render_data_type = symbol_to_data_type_upcase(data_type)
        @render_view = RenderView::TABLE
        self
      end

      def set_datatype(data_type)
        @render_data_type = symbol_to_data_type_upcase(data_type)
        self
      end

      private

      
      def response_datatype
        self["datatype"] && self["datatype"].to_sym
      end

      def hash_part
        keys.inject(Hash.new){|h,k|h.merge(k => self[k])}
      end
      
      def symbol_to_data_type_upcase(data_type)
        return data_type.nil? ? nil : data_type.to_s.upcase
      end
    end
  end
end
