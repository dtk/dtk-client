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
module DTK::DSL; class FileParser
  class Assembly < self
    class OutputArray < FileParser::OutputArray
      def self.keys_for_row
        [:assembly_name,:components]
      end
    end

    class V2 < self
      def parse_hash_content(input_hash)
        ret = OutputArray.new
        assembly_hash = OutputHash.new(
          :assembly_name => input_hash[:name],
          :components => Component.parse_hash_content(input_hash[:assembly]||{})                                       
        )
        ret << assembly_hash
        ret
      end

      class Component
        class OutputArray < FileParser::OutputArray
          def self.keys_for_row
            [:component_name,:module_name,:node_name]
          end
        end

        def self.parse_hash_content(input_hash)
          ret = OutputArray.new
          (input_hash[:nodes]||{}).each_pair do |node_name,node_info|
            (node_info[:components]||{}).each do |component|
              mod_component_name = (component.kind_of?(Hash) ? component.keys.first : component)
              module_name,component_name = ret_module_and_component_names(mod_component_name)
              ret << OutputHash.new(:component_name => component_name,:module_name => module_name,:node_name => node_name)
            end
          end
          ret
        end
       private

        #returns [module_name,component_name]
        def self.ret_module_and_component_names(mod_component_name)
          if mod_component_name =~ /(^[^:]+)::([^:]+$)/
            [$1,$2]
          else
            [mod_component_name,mod_component_name]
          end
        end
      end

    end
  end
end; end; end
