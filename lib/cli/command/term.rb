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
module DTK::Client; module CLI
  module Command
    ##
    # Common terms used in commands
    module Term
      module Flag
        Info = Struct.new(:opt, :arg_name, :desc)

        def self.service_instance
          Info.new(:s, 'SERVICE-INSTANCE-NAME', 'Service instance name')
        end

        #### 
        # general methods
        def self.option_ref(flag_name)
          flag_info = send(flag_name)
          "-#{flag_info.opt} #{flag_info.arg_name}"
        end

        def self.opt(flag_name)
          send(flag_name).opt
        end
      end
    end
  end
end; end
