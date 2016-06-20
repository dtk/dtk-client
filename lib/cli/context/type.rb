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
    module Type
      require_relative('type/top')
      require_relative('type/module')
      require_relative('type/service')

      # This function can have the side of updating base_dsl_file_obj
      def self.create_context!(base_dsl_file_obj)
        if path = base_dsl_file_obj.path?
          case base_dsl_file_obj.file_type.type
          when :common_module 
            Module.new(base_dsl_file_obj)
          when :service_instance  
            Service.new(base_dsl_file_obj)
          else 
            raise Error, "Unexpected file_type '#{file_type.type}'"
          end
        else
          Top.new(base_dsl_file_obj)
        end
      end
    end
  end
end
