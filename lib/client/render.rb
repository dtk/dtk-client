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
    module Type
      TABLE  = 'table'
      SIMPLE = 'simple'

      ALL = [TABLE, SIMPLE]
      DEFAULT = SIMPLE

      # TODO: DTK-2554: removed below and put in simple, which is yaml
      # SIMPLE_LIST     = 'simple_list'
      # PRETTY_PRINT    = 'hash_pretty_print'
      # AUG_SIMPLE_LIST = 'augmented_simple_list'
    end
    
    Type::ALL.each { |render_type| require_relative("render/view/#{render_type}") }

    extend Auxiliary

    attr_reader :render_type, :semantic_datatype
    def initialize(render_type, semantic_datatype = nil)
      @render_type       = render_type
      @semantic_datatype = semantic_datatype
    end
    private :initialize

    # opts can have keys
    #  :semantic_datatype
    #  :adapter - way to pass in already created adapter
    #  :print_error_table - Boolean (default: false)
    #  :table_definition - pverride to table def associated with semantic_datatype
    # 
    # value returned is Boolean indicating whether any additional print needed
    def self.render(ruby_obj, opts = {})
      render_type = opts[:render_type]
      if render_type == Type::TABLE
        render_opts = {
          :print_error_table => opts[:print_error_table],
        }
        get_adapter(Type::TABLE, opts).render(ruby_obj, render_opts)
        # saying no additional print needed 
        false
      elsif ruby_obj.kind_of?(Hash)
        get_adapter(render_type, opts).render(ruby_obj)
      elsif ruby_obj.kind_of?(Array)
        get_adapter(render_type, opts).render(ruby_obj)
      elsif ruby_obj.kind_of?(String)
        ruby_obj
      else
        raise Error.new('ruby_obj has unexpected type')
      end
    end
    
    private

    # opts can have keys
    #  :adapter - way to pass in already created adapter
    #  :semantic_datatype
    def self.get_adapter(render_type, opts = {})
      return opts[:adapter] if opts[:adapter]
      
      raise Error.new('No type is given') unless render_type
      
      AdapterCache.get?(render_type, opts[:semantic_datatype]) || AdapterCache.set(create_adapter(render_type, opts))
    end

    def self.create_adapter(render_type, opts = {})
      klass = const_get cap_form(render_type) 
      klass.new(opts)
    end
    
    module AdapterCache
      STORE_SIMPLE = {}
      STORE_AUG = {}

      def self.get?(render_type, semantic_datatype = nil)
        if semantic_datatype
          (STORE_AUG[render_type]||{})[semantic_datatype]
        else
          STORE_SIMPLE[render_type]
        end
      end
      
      def self.set(adapter)
        if semantic_datatype = adapter.semantic_datatype
          (STORE_AUG[adapter.render_type] ||= {})[semantic_datatype] = adapter
        else
          STORE_SIMPLE[adapter.render_type] = adapter
        end
        adapter
      end
    end
  end
end
