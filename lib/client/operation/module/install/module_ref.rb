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
  class Operation::Module::Install
    class ModuleRef < ::DTK::Client::ModuleRef
      # opts can have keys:
      #  :namespace
      #  :module_name
      #  :version
      #  :is_base_module
      #  :module_installed
      def initialize(opts = {})
        super
        @is_base_module   = opts[:is_base_module]
        @module_installed = opts[:module_installed]
      end

      def is_base_module?
        @is_base_module
      end

      def module_installed?(parent)
        if @module_installed.nil?
          @module_installed ||= parent.query_if_component_module_is_installed?
        else
          @module_installed
        end
      end
    end
  end
end


