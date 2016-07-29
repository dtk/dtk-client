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
    class Attributes < ::Hash
      def initialize(context)
        @context = context

        # special_keys computed on demand
        @special_keys = {}
      end

      def [](key)
        # special processing on demand
        case key
        when :module_ref
          module_ref
        else
          super
        end
      end

      private

      def module_ref
         if @special_keys.has_key?(:module_ref)
           @special_keys[:module_ref] = (@context.base_module_ref? if @context.respond_to?(:base_module_ref?))
           @special_keys[:module_ref]
         else
           @special_keys[:module_ref] = (@context.base_module_ref? if @context.respond_to?(:base_module_ref?))
         end
      end

    end
  end
end
