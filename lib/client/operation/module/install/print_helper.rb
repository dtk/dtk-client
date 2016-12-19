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
module DTK::Client; class Operation::Module
  class Install
    class PrintHelper
      include Install::Mixin

      # opts can have keys:
      #   :indent_length
      #   :module_ref
      def initialize(opts = {})
        @indent_length = opts[:indent_length] || 0
        @module_ref    = opts[:module_ref]
      end

      def set_module_ref!(module_ref)
        @module_ref = module_ref
        self
      end
      
      # Continuation messages, which dont have carriage return
      def print_continuation_installing_dependency
        print_continuation "Installing dependent module '#{pretty_print_module}'"
      end

      def print_continuation_installing_base_module
        print_continuation "Installing base module '#{pretty_print_module}' from #{Term::DTKN_CATALOG}", :color => :yellow
      end

      def print_continuation_pulling_dependency_update
        print_continuation "Pulling update to dependent module '#{pretty_print_module}'"
      end

      ###  End: Continuation messages

      def print_warning(msg)
        OsUtil.print_warning(msg)
      end

      def print_getting_dependencies
        OsUtil.print_info("Getting dependent module info for '#{pretty_print_module}' from #{Term::DTKN_CATALOG} #{Term::CONTINUATION}")
      end

      def print_installing_dependencies
        OsUtil.print_info("Installing dependent modules from #{Term::DTKN_CATALOG} #{Term::CONTINUATION}")
      end

      def print_using_installed_dependent_module
        OsUtil.print("Using installed dependent module '#{pretty_print_module}'")
      end

      def print_terminated_installation
        OsUtil.print_warning("Terminated installation of module '#{pretty_print_module}'")
      end

      def print_done_message
        OsUtil.print('Done.', :yellow)
      end

      # For prompts
      def dependent_module_update_prompt
        "#{indent}Do you want to update dependent module '#{pretty_print_module}' from the #{Term::DTKN_CATALOG}?"
      end

      private
      

      # opts can have keys:
      #   :color
      def print_continuation(msg, opts = {})
        print_without_cr("#{@indent}#{msg} #{Term::CONTINUATION} ", :color => opts[:color])
      end

      # print without carriage return
      # opts can have keys:
      #   :color
      def print_without_cr(msg, opts = {})
        # Using print to avoid adding cr at the end.
        print(opts[:color] ? msg.colorize(opts[:color]) : msg)
      end

      def pretty_print_module
        @module_ref.pretty_print
      end

      def indent
        ' ' * @indent_length
      end

      INDENT_BUMP = 2
      def increase_indent!
        @indent_length += INDENT_BUMP
      end
      
      module Term
        DTKN_CATALOG = 'dtkn catalog'
        CONTINUATION = '...'
      end
      
    end
  end
end; end


