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

    def self.render(command_class, ruby_obj, type, data_type, adapter=nil, print_error_table=false)
      adapter ||= get_adapter(type,command_class,data_type)
      if type == Type::TABLE
        # for table there is only one rendering, we use command class to
        # determine output of the table
        adapter.render(ruby_obj, command_class, data_type, nil, print_error_table)
        
        # saying no additional print needed (see core class)
        return false
      elsif ruby_obj.kind_of?(Hash)
        adapter.render(ruby_obj)
      elsif ruby_obj.kind_of?(Array)
        ruby_obj.map{|el|render(command_class,el,type,nil,adapter)}
      elsif ruby_obj.kind_of?(String)
        ruby_obj
      else
        raise Error.new('ruby_obj has unexepected type')
      end
    end
    
    private

    def self.get_adapter(type, command_class, data_type=nil)
      data_type_index = use_data_type_index?(command_class, data_type)
      cached = 
        if data_type_index
          ((AdapterCacheAug[type]||{})[command_class]||{})[data_type_index]
        else
          (AdapterCache[type]||{})[command_class]
        end               
      
      return cached if cached
      require_relative("render/#{type}")
      klass = const_get cap_form(type) 
      if data_type_index
        AdapterCacheAug[type] ||= Hash.new
        AdapterCacheAug[type][command_class] ||= Hash.new
        AdapterCacheAug[type][command_class][data_type_index] = klass.new(type,command_class,data_type_index)
      else
        AdapterCache[type] ||= Hash.new
        AdapterCache[type][command_class] = klass.new(type,command_class)               
      end
    end
    
    AdapterCache = Hash.new
    AdapterCacheAug = Hash.new

    #data_type_index is used if there is adata type passed and it is different than command_class default data type
    def self.use_data_type_index?(command_class, data_type)
      if data_type
        data_type_index = data_type.downcase
        if data_type_index != snake_form(command_class)
          data_type_index
        end
      end
    end
  end
end
