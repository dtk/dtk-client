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
module DTK::Client::CLI
  class Context
    module Type
      class Module < Context
        include Command::Module
        include Command::Service        

        private
        
        def add_command_defs!
          add_command :module
          # add_command :service needed for stage and deploy commands
          add_command :service
        end
        
        def attributes
          ret = super
          if module_ref = base_module_ref?
            ret.merge!(:module_ref => module_ref)
          end
          ret
        end
        
      end
    end
  end
end
