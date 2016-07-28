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
    module Token
      require_relative('token/flag')
      require_relative('token/switch')

      # Flags

      # Flag::Info = Struct.new(:opt, :arg_name, :desc)

      def self.version
        Flag::Info.new(:v, 'VERSION', 'Version')
      end
      
      def self.service_instance
        Flag::Info.new(:s, 'SERVICE-INSTANCE', 'Service instance name')
      end
      
      def self.target_service_instance
        Flag::Info.new(:t, 'TARGET-SERVICE-INSTANCE', 'Target service instance name')
      end
      
      def self.namespace_module_name
        Flag::Info.new(:m, 'NAMESPACE/MODULE-NAME', 'Module name with namespace')
      end

      # switches

      # Switch::Info = Struct.new(:opt, :desc, :default_value)

      def self.force
        Switch::Info.new(:f, 'Force', false)
      end

      def self.skip_prompt
        Switch::Info.new(:y, 'Skip prompt', false)
      end

      #### 
      # general methods
      def self.opt?(canonical_name)
        send(canonical_name).opt if respond_to?(canonical_name) 
      end
      
      def self.option_ref(canonical_name)
        flag_info = send(canonical_name)
        "-#{flag_info.opt} #{flag_info.arg__name}"
      end

    end
  end
end

