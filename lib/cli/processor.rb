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
  module CLI
    # Delegation module for wrapping third party library used to do parsing
    class Processor
      module Plugin
        DEFAULT = :gli
        DEFAULT_CLASS_NAME = "#{DEFAULT.to_s.capitalize}"
        # autoload DEFAULT_CLASS_NAME.to_sym, "plugin/#{DEFAULT_PLUGIN}"
        require_relative "processor/plugin/#{DEFAULT}"
        def self.default_class
          const_get DEFAULT_CLASS_NAME
        end
      end
      
      module Methods
        def self.all
          [:arg_name, :command, :default_value, :desc, :flag, :switch, :add_command_defaults!, :add_command_hooks!, :run_and_return_command_response]
        end
      end
      
      def self.default
        new(Plugin.default_class)
      end
      
      def initialize(plugin_class)
        @plugin = plugin_class.new
      end
      private :initialize

      def method_missing(method, *args, &body)
        Methods.all.include?(method) ? @plugin.send(method, *args, &body) : super
      end
      
      def respond_to?(method)
        Methods.all.include?(method) or super
      end
    end
  end
end

  


