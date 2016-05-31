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
    class ModuleRef

      attr_reader :namespace, :module_name, :version

      def initialize(module_ref_hash)
        @namespace   = module_ref_hash[:namespace]
        @module_name = module_ref_hash[:module_name]
        @version     = module_ref_hash[:version]
      end

      NAMESPACE_MOD_DELIM = ':'
      def reference
        ret = "#{namespace}#{NAMESPACE_MOD_DELIM}/#{module_name}"
        ret << "(#{version})" if @version
        ret
      end
    end
  end
end


