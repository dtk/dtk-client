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
  class CLI::Context
    class Type
      module Mixin
        private 
        
        # This function can have the side of updating @base_dsl_file_obj
        def determine_type!
          if path = @base_dsl_file_obj.path?
          else
            Type::Top
          end
        end
      end

      class Service  < self
        def self.applicable_commands
          [:service]
        end
      end

      class Module  < self
        def self.applicable_commands
          [:module]
        end
      end

      ALL_TYPES = [Service, Module]
      class Top < self
        def self.applicable_commands
          ALL_TYPES.map { |type_class| type_class.send(:applicable_commands)}.flatten(1).uniq
        end
      end
    end
  end
end
