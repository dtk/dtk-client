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
  class Operation::Service
    class ListAttributes < self
      LEGAL_FORMAT_VALUES = [:table, :yaml, :json]
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          service_instance = args.required(:service_instance)
          links            = args[:links]
          # node             = args[:node]
          # component        = args[:component]
          all              = args[:all]
          format           = check_and_ret_format(args)

          query_string_hash = QueryStringHash.new(
            :links?            => links,
            # :node_id?          => node,
            :all               => all,
            # :filter_component? => component,
            :format            => format
          )
          
          response = rest_get("#{BaseRoute}/#{service_instance}/attributes", query_string_hash)
          
          case format
          when :table
            response.set_render_as_table!
          when :yaml
            require 'byebug'; byebug
            response
          when :json
            # TODO: stub to treat json
            legal_formats = LEGAL_FORMAT_VALUES - [:json]
            raise Error::Usage, "Illegal option -f [--format]; legal values are: #{legal_formats.join(', ')}"
          else
            raise Error, "Should not reach here since format checked already"
          end
        end
      end

      private

      def self.check_and_ret_format(args = {})
        format = (args[:format] || 'table').downcase.to_sym
        unless LEGAL_FORMAT_VALUES.include?(format)
          raise Error::Usage, "Illegal option -f [--format]; legal values are: #{LEGAL_FORMAT_VALUES.join(', ')}"
        end
        format
      end
    end
  end
end
