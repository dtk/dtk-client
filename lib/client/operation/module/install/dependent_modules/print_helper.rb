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
module DTK::Client; class Operation::Module::Install
  class DependentModules
    class PrintHelper
      include DependentModules::Mixin

      # opts can have keys:
      #   :print_newline
      #   :indent_length
      def initialize(opts = {})
        # TODO: is @print_newline still needed?
        @print_newline = opts[:print_newline] || false
        @indent_length = opts[:indent_length] || 0
        @module_ref    = nil
      end

      def set_module_ref!(module_ref)
        @module_ref = module_ref
        self
      end
      
      def dependent_module_update_prompt
        "#{indent}Do you want to update dependent module '#{full_module_name}' from the #{Term::DTKN_CATALOG}?"
      end

      def print_install_msg
        print_opts = {
          :module_name => module_name,
          :namespace   => namespace,
          :version     => version
        }
        print_newline?
        print_continuation "#{@indent}Installing module '#{DTK::Common::PrettyPrintForm.module_ref(module_name, print_opts)}' from #{Term::DTKN_CATALOG}"
      end

      def print_pulling_update
        print_newline?
        print_continuation "#{indent}Pulling update to module '#{full_module_name}' from #{Term::DTKN_CATALOG}"
      end

      def print_done_message
        OsUtil.print('Done.', :yellow)
        @print_newline = false
      end
      
      # TODO: needs cleaning up and tehn put back in flow
      def print_using_installed_module_messgage
        # special case where, after importing dependencies of dependency, comes a using message
        print_newline?
        print_opts = {
          :namespace => module_ref.namespace,
          :version   => module_ref.version
        }
        OsUtil.print("#{indent}Using module '#{DTK::Common::PrettyPrintForm.module_ref(module_ref.module_name, print_opts)}'")
        @print_newline = false
      end
      
      private

      def print_continuation(msg)
        print_without_cr "#{msg} ... "
      end

      # print without carriage return
      def print_without_cr(msg)
        # Using print to avoid adding cr at the end.
        print msg
      end

      def print_newline?
        print "\n" if @print_newline
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
      end
      
    end
  end
end; end


