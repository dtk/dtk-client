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
  class Render
    class Table 
      requiare_relative('table/processor')

      # opts can have keys
      #  :semantic_datatype (required)
      def initialize(render_type, opts = {})
        unless semantic_datatype = opts[:semantic_datatype]
          raise Error, 'Missing opts[:semantic_datatype] value'
        end
        super(render_type, semantic_datatype)
        @table_definition = get_table_definition?(semantic_datatype)
      end

      # opts can have keys
      #   :print_error_table - Boolean (default: false)
      #   :table_definition - if set overrides the one associated with the object
      def render(data, opts = {})
        unless table_definition = opts[:table_definition] || @table_definition
          raise Error, 'Missing table definition'
        end
        Processor.render(data, table_definition, opts)
      end

      private
      
      TableDefinition = Struct.new(:mapping, :order_definition)
      def get_table_definition?(semantic_datatype)
        if table_def_hash = (table_definitions || {})[table_def_index_from_semantic_datatype(semantic_datatype)]
          TableDefinition.new(table_def_hash['mapping'], table_def_hash['order'])
        end
      end

      def table_def_index_from_semantic_datatype(semantic_datatype)
        semantic_datatype
      end

      def table_definitions
        # TODO: put back in caching after take into account :meta_table_ttl
        # @@table_definitions_metadata ||= get_table_definitions_metadata 
        get_table_definitions
      end

      # get all table definitions from json file
      def get_table_definitions
        content = DiskCacher.new.fetch("table_metadata", Configuration.get(:meta_table_ttl))
        raise Error, "Table metadata is empty, please contact DTK team." if content.empty?
        JSON.parse(content)
      end
    end
  end
end
