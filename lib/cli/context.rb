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
      require_relative('context/type')
      require_relative('context/attributes')

      def self.determine_context
#stub
dir_path = File.expand_path('../../examples/simple/test', File.dirname(__FILE__))

#dir_path = nil
        base_dsl_file_obj = base_dsl_file_obj(:dir_path => dir_path)
        Type.create_context!(base_dsl_file_obj)
      end

      def initialize(base_dsl_file_obj)
        @base_dsl_file_obj   = base_dsl_file_obj
        @command_processor   = Processor.default
        @context_attributes  = attributes
        add_command_defs_defaults_and_hooks!
      end
      private :initialize

      def run_and_return_response_object(argv)
        @command_processor.run_and_return_response_object(argv)
      end
      
      def method_missing(method, *args, &body)
        command_processor_object_methods.include?(method) ? @command_processor.send(method, *args, &body) : super
      end
      
      def respond_to?(method)
        command_processor_object_methods.include?(method) or super
      end
      
      private

      attr_reader :context_attributes

      # The method 'attributes' can be overwritten
      def attributes
        Attributes.new
      end

      FILE_TYPES = 
        [
         ::DTK::DSL::FileType::CommonModule,
         ::DTK::DSL::FileType::ServiceInstance
        ]

      # opts can have keys
      #   :dir_path
      def  self.base_dsl_file_obj(opts = {}) 
        file_obj = DirectoryParser.matching_file_obj?(FILE_TYPES, opts)
        file_obj.add_parse_content!(:common_module_summary)
      end

      def add_command_defs!
        raise Error::NoMethodForConcreteClass.new(self.class)
      end

      def add_command_defs_defaults_and_hooks!
        add_command_defaults!
        add_command_defs!
        add_command_hooks!
        self
      end

      def command_processor_object_methods
        @@command_processor_object_methods ||= Processor::Methods.all 
      end

      def base_dsl_hash_content?
        @base_dsl_file_obj.hash_content?
      end

    end
  end
end
