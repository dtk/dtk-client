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
class DTK::DSL::FileParser::Template
  class V1
    class DependentModules < self
      def parse!
        input_array.each_with_index do |module_ref, i|
          @output << parse_child(:module_ref, module_ref, :parent_key => parent_key?(i))
        end
      end
    end
  end
end
=begin
        component_modules = input_hash[:component_modules]
        return ret if component_modules.empty?
        
        component_modules.each do |component_module,v|
          new_el = Output::Hash.new(:component_module => component_module)
          parse_error = true
          if v.kind_of?(InputHash) and v.only_has_keys?(:version,:remote_namespace,:namespace,:external_ref) and not v.empty?
            parse_error = false
            
            namespace    = v[:namespace]
            namespace    = v[:remote_namespace] if namespace.empty? # TODO: for legacy
            
            # to extend module_refs.yaml attributes add code here
            new_el.merge_non_empty!(:version_info => v[:version])
            new_el.merge_non_empty!(:remote_namespace => namespace)
            new_el.merge_non_empty!(:external_ref => v[:external_ref])
          elsif v.kind_of?(String)
            parse_error = false
            new_el.merge_non_empty!(:version_info => v)
          elsif v.nil?
            parse_error = false
          end
          if parse_error
            err_msg = (parse_error.kind_of?(String) ? parse_error : "Ill-formed term (#{v.inspect})")
            raise Error::Usage.new(err_msg)
          else
            ret << new_el
          end
        end
        ret
      end
    end
    
    class OutputArray < FileParser::OutputArray
      def self.keys_for_row
        [:component_module, :version_info, :remote_namespace, :external_ref]
      end
      def self.has_required_keys?(hash_el)
        !hash_el[:component_module].nil?
      end
    end
  end
end; end
=end
