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
      SIMPLE_LIST     = 'simple_list'
      TABLE           = 'table_print'
      PRETTY_PRINT    = 'hash_pretty_print'
      AUG_SIMPLE_LIST = 'augmented_simple_list'
    end

    include Auxiliary

    def initialize(type, command_class, data_type_index=nil)
      @command_class = command_class
      @data_type_index = data_type_index
    end
    private :initialize

    # opts can have keys
    #  :type - One of Render::Type constants
    #  :command_class
    #  :data_type
    #  :adapter - way to pass in already created adapter
    #  :print_error_table - Boolean (default: false)
    # value returned is Boolean indicating whether any additional print needed
    def self.render(ruby_obj, opts = {})
      type = opts[:type]
      if type == Type::TABLE
        # for table there is only one rendering, we use command class to
        # determine output of the table
        get_adapter(type, opts).render(ruby_obj, opts)
        # saying no additional print needed 
        false
      elsif ruby_obj.kind_of?(Hash)
        get_adapter(type, opts).render(ruby_obj)
      elsif ruby_obj.kind_of?(Array)
        ruby_obj.map{ |el| render(el, opts) }
      elsif ruby_obj.kind_of?(String)
        ruby_obj
      else
        raise Error.new('ruby_obj has unexpected type')
      end
    end
    
    private

    # opts can have keys
    #  :adapter - way to pass in already created adapter
    #  :command_class
    #  :data_type
    def self.get_adapter(type, opts = {})
     return opts[:adapter] if opts[:adapter]

      raise Error.new('No type is given') unless type

      command_class = opts[:command_class]
      data_type = opts[:data_type]

      data_type_index = use_data_type_index?(command_class, data_type)
      cached_adapter = AdapterCache.get?(type, command_class, data_type_index)
      return cached_adapter if cached_adapter

      require_relative("render/#{type}")
      klass = const_get cap_form(type) 

      if data_type_index
        AdapterCache::Aug.set(klass.new(type, command_class, data_type_index))
      else
        AdapterCache::Simple.set(klass.new(type, command_class))
      end
    end
    
    #data_type_index is used if there is adata type passed and it is different than command_class default data type
    def self.use_data_type_index?(command_class, data_type)
      if data_type
        data_type_index = data_type.downcase
        if data_type_index != snake_form(command_class)
          data_type_index
        end
      end
    end

    module AdapterCache
      def self.get?(type, command_class, data_type_index)
        data_type_index ?
        ((Aug::STORE[type]||{})[command_class]||{})[data_type_index] :
          (Simple::STORE[type]||{})[command_class]
      end
      module Simple
        STORE = {}
        def self.set(adapter)
          (STORE[adapter.type] ||= {})[adapter.command_class]  = adapter
        end
      end
      module Aug
        def self.set(adapter)
          ((STORE[adapter.type] ||= {})[adapter.command_class] ||= {})[adapter.data_type_index] = adapter
        end
      end
    end
  end
end
