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
#dir_path = File.expand_path('../../examples/spark', File.dirname(__FILE__))
#base_dsl_file_obj = base_dsl_file_obj(:dir_path => dir_path)
        base_dsl_file_obj = base_dsl_file_obj()
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

      def value_from_base_dsl_file?(key)
        case key
        when :module_ref 
          module_ref_from_base_dsl_file?
        when :service_instance 
          service_instance_from_base_dsl_file?
        end
      end

      private

      attr_reader :context_attributes, :base_dsl_file_obj

      def module_ref_from_base_dsl_file?
        parsed_module = base_dsl_file_obj.parse_content(:common_module_summary)
        namespace   = parsed_module.val(:Namespace)
        module_name = parsed_module.val(:ModuleName)
        version     = parsed_module.val(:ModuleVersion) || 'master'
        if namespace and module_name
          client_dir_path = base_dsl_file_obj.parent_dir?
          ModuleRef.new(:namespace => namespace, :module_name => module_name, :version => version, :client_dir_path => client_dir_path)
        end
      end

      def service_instance_from_base_dsl_file?
        raise_error_when_missing_context(:service_instance) unless base_dsl_file_obj.file_type == DTK::DSL::FileType::ServiceInstance
        base_dsl_file_obj.parse_content(:service_module_summary).val(:Name)
      end

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

      def module_ref_in_options_or_context(options)
        module_ref_in_options_or_context?(options) || raise_error_when_missing_context(:module_ref, options)
      end

      def module_ref_in_options_or_context?(options)
        if options[:module_ref]
          opts = {:namespace_module_name => options[:module_ref]}
          opts.merge!(:version => options[:version]) if options[:version]
          ModuleRef.new(opts)
        else
          if module_dir_path = options[:directory_path]
            set_base_dsl_file_obj!(:dir_path => module_dir_path)
          end
          context_attributes[:module_ref]
        end
      end

      def service_instance_in_options_or_context(options)
        service_instance_in_options_or_context?(options) || raise_error_when_missing_context(:service_instance, options)
      end
      
      def service_instance_in_options_or_context?(options)
        if ret = options[:service_instance]
          ret
        else
          if module_dir_path = options[:directory_path]
            set_base_dsl_file_obj!(:dir_path => module_dir_path)
          end
          context_attributes[:service_instance]
        end
      end


      ERROR_MSG_MAPPING = {
        :service_instance => 'service instance',
        :module_ref       => 'mdoule'
      }
      def raise_error_when_missing_context(type, options = {})
        @base_dsl_file_obj.raise_error_if_no_content
        # TODO: not sure if below can be reached
        error_msg = 
          if options[:directory_path]
            "Bad #{ERROR_MSG_MAPPING[type]} directory path '#{options[:directory_path]}'"
          else
            "This command must be executed from within a #{ERROR_MSG_MAPPING[type]} directory or a directory path must be given using option '#{option_ref(:directory_path)}'"
          end
        raise Error::Usage, error_msg
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
