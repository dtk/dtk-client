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
#testing stub
dir_path = File.expand_path('../../examples/spark', File.dirname(__FILE__))
base_dsl_file_obj = base_dsl_file_obj(:dir_path => dir_path)
#        base_dsl_file_obj = base_dsl_file_obj()
        Type.create_context!(base_dsl_file_obj)
      end

      def initialize(base_dsl_file_obj)
        @base_dsl_file_obj   = base_dsl_file_obj
        @command_processor   = Processor.default
        @context_attributes  = Attributes.new(self)
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

      def base_module_ref?
        parsed_module = @base_dsl_file_obj.parse_content(:common_module_summary)
        namespace   = parsed_module.val(:Namespace)
        module_name = parsed_module.val(:ModuleName)
        ModuleRef.new(:namespace => namespace, :module_name => module_name) if namespace and module_name
      end

      private

      attr_reader :context_attributes

      # opts can have keys
      #   :dir_path
      def set_base_dsl_file_obj!(opts = {})
        @base_dsl_file_obj = self.class.base_dsl_file_obj(opts)
      end

      # opts can have keys
      #   :dir_path
      def  self.base_dsl_file_obj(opts = {}) 
        DirectoryParser.matching_file_obj?(FILE_TYPES, opts)
      end
      FILE_TYPES = 
        [
         ::DTK::DSL::FileType::CommonModule,
         ::DTK::DSL::FileType::ServiceInstance
        ]


      def module_ref_in_context_or_options(options)
        if options[:namespace_module_name]
          ModuleRef.new(:namespace_module_name => options[:namespace_module_name])
        elsif module_ref = context_attributes[:module_ref]
          module_ref
        else
          raise Error::Usage, "This command must be executed from within a module or a module reference must be given using option '#{option_ref(:namespace_module_name)}'"
        end
      end

      # Methods related to adding cli command definitions 
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

    end
  end
end
