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
    # Object that provides the context for interpreting commands
    class Context
      require_relative('context/attributes')
      require_relative('context/base_dsl_file')
      
      ALL_CONTEXTS = [:service, :module]

      (ALL_CONTEXTS + [:top]).each { |context| require_relative("context/type/#{context}") }
      
      def initialize
        @command_processor = Processor.default
        @context_attributes = attributes
        # @base_dsl_file_obj gets computed on demand
        @base_dsl_file_obj = nil
      end
      private :initialize 
      
      def self.determine_context
        get_and_set_cache { create_when_in_specific_context? || create_default }
      end
      
      def run_and_return_response_object(argv)
        @command_processor.run_and_return_response_object(argv)
      end
      
      def method_missing(method, *args, &body)
        command_processor_object_methods.include?(method) ? @command_processor.send(method, *args, &body) : super
      end
      
      def respond_to?(method)
        command_processor_object_methods.include?(method) or super
      end
      
      def add_command_defs_defaults_and_hooks!
        add_command_defaults!
        add_command_defs!
        add_command_hooks!
        self
      end

      def base_dsl_file_obj?
        @base_dsl_file_obj ||= BaseDslFile.find?
      end

      private

      # The method 'create_attributes' can be ovewritten
      def attributes
        Attributes.new
      end
      
      attr_reader :context_attributes
      
      def self.create
        new.add_command_defs_defaults_and_hooks!
      end
      
      def self.create_default
        Top.create
      end
      
      def command_processor_object_methods
        @@command_processor_object_methods ||= Processor::Methods.all 
      end
      
      def self.get_and_set_cache
        # TODO: stub
        yield
      end
      
      def self.create_when_in_specific_context?
        # TODO: stub 
        nil
        # Module.create
        # Service.create
      end
    end
  end
end
