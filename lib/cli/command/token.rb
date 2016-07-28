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
  module CLI::Command
    ##
    # Common terms used in commands
    class Token < ::Hash
      require_relative('token/mixin')
      require_relative('token/class_mixin')
      require_relative('token/flag')
      require_relative('token/switch')

      include Mixin
      extend ClassMixin
      
      TOKENS = {
        # flags
        # Flag constructor args order: key, arg_name, desc, opts={}
        :commit_message          => Flag.new(:m, 'COMMIT-MSG', 'Commit message'),
        :namespace_module_name   => Flag.new(:m, 'NAMESPACE/MODULE-NAME', 'Module name with namespace'),
        :version                 => Flag.new(:v, 'VERSION', 'Version'),
        :service_instance        => Flag.new(:s, 'SERVICE-INSTANCE', 'Service instance name'),
        :target_service_instance => Flag.new(:t, 'TARGET-SERVICE-INSTANCE', 'Target service instance name'),
        
        # switches
        # Switch constructor args order: key, desc, opts={}
        
        :force       => Switch.new(:f, 'Force'),
        :purge       => Switch.new(:p, 'Purge'),
        :push        => Switch.new(:p, 'Push changes'),
        :skip_prompt => Switch.new(:y, 'Skip prompt')
      }
      
    end
  end
end
