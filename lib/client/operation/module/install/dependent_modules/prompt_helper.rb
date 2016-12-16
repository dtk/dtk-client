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
  class Operation::Module::Install::DependentModules
    class PromptHelper
      attr_reader :update_all, :update_none
      # opts can have keys
      #  :update_all
      #  :update_none
      def initialize(opts = {})
        @update_all  = opts[:update_all]
        @update_none = opts[:update_none]
      end

      PROMPT_OPTIONS = %w(all none)
      def pull_module_update?(print_helper)
        return false if @update_none
        return true if @update_all

        update = Console.confirmation_prompt_additional_options(print_helper.dependent_module_update_prompt, PROMPT_OPTIONS)
        return false unless update
        
        if update.eql?('all')
          @update_all = true
          true
        elsif update.eql?('none')
          @update_none = true
          false
        else
          # means update this one
          true
        end
      end

    end
  end
end


