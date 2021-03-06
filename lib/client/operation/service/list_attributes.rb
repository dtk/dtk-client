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
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          service_instance = args.required(:service_instance)
          links            = args[:links]
          # node             = args[:node]
          name             = args[:attribute_name]
          component        = args[:component]
          format           = args[:format] || 'table'
          format.downcase!

          if component && name 
            raise Error::Usage, "Command options ATTRIBUTE NAME and --component cannot be used at the same time."
          end

          query_string_hash = QueryStringHash.new(
            :links?            => links,
            # :node_id?          => node,
            :filter_component? => component,
            :format            => format,
            :attribute_name    => name
          )
          
          response = rest_get("#{BaseRoute}/#{service_instance}/attributes", query_string_hash)
          
          case format
          when 'table'
            response.set_render_as_table!
          when 'yaml'
            response
          else
            raise Error::Usage, "Please enter valid format: TABLE, YAML"
          end
        end
      end
    end
  end
end
