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
        base_dsl_file_obj = base_dsl_file_obj()
        Type.create_context!(base_dsl_file_obj)
      end

      def initialize(base_dsl_file_obj)
        @base_dsl_file_obj   = base_dsl_file_obj
        @command_processor   = Processor.default
        @context_attributes  = Attributes.new(self)
        @options             = {}
        add_command_defs_defaults_and_hooks!
      end
      private :initialize

      def run_and_return_response_object(argv)
        @flag = true if argv.include?('-d')
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

      def module_ref_object_from_options_or_context(options, module_refs_opts = {})
        module_ref_object_from_options_or_context?(options, module_refs_opts) || raise_error_when_missing_context(:module_ref, options)
      end

      attr_reader :base_dsl_file_obj

      private

      attr_reader :context_attributes

      def module_ref_from_base_dsl_file?
        parsed_module_hash = parse_module_content_and_create_hash
        namespace          = parsed_module_hash[:namespace]
        module_name        = parsed_module_hash[:module_name]
        version            = parsed_module_hash[:version] || 'master'

        if namespace and module_name
          client_dir_path = base_dsl_file_obj.parent_dir?
          ModuleRef.new(:namespace => namespace, :module_name => module_name, :version => version, :client_dir_path => client_dir_path)
        end
      end

      def parse_module_content_and_create_hash
        parsed_hash = {}

        begin
          parsed_module = base_dsl_file_obj.parse_content(:common_module_summary)
          parsed_hash = {
            :namespace   => parsed_module.val(:Namespace),
            :module_name => parsed_module.val(:ModuleName),
            :version     => parsed_module.val(:ModuleVersion)
          }
        rescue Error::Usage => error
          # if there is syntax error in dsl, we still want to get namespace, name, and version
          # will be used in commands like 'dtk module uninstall', ... where we want to uninstall module even if parsing errors in yaml
          if content = @options[:ignore_parsing_errors] && base_dsl_file_obj.content
            ret_module_info_from_raw_content(parsed_hash, content)
          else
            raise error
          end
        end

        parsed_hash
      end

      # get namespace, name and version from raw file content and return as parsed_hash
      def ret_module_info_from_raw_content(parsed_hash, content)
        info_found = lambda {|input_hash| (input_hash[:namespace] && input_hash[:module_name] && input_hash[:version]) }

        content.each_line do |line|
          if line_match = line.match(/(^module:)(.*)/)
            name_found      = true
            full_name       = line_match[2].strip
            namespace, name = full_name.split('/')
            parsed_hash.merge!(:namespace => namespace, :module_name => name)
          elsif line_match = line.match(/(^version:)(.*)/)
            version_found = true
            parsed_hash.merge!(:version => line_match[2].strip)
          end

          break if info_found.call(parsed_hash)
        end
      end

      def service_instance_from_base_dsl_file?
        #raise_error_when_missing_context(:service_instance) unless base_dsl_file_obj.file_type == DTK::DSL::FileType::ServiceInstance::DSLFile::Top
        # base_dsl_file_obj.file_type == DTK::DSL::FileType::ServiceInstance::DSLFile::Top
        base_dsl_file_obj.file_type == DTK::DSL::FileType::ServiceInstance::DSLFile::Top::Hidden
        parse_conent_and_ret_service_name
      end

      def parse_conent_and_ret_service_name
        begin
          base_dsl_file_obj.parse_content(:service_module_summary).val(:Name)
        rescue Error::Usage => error
          if content = @options[:ignore_parsing_errors] && base_dsl_file_obj.content
            ret_service_name_from_raw_content(content)
          else
            raise error
          end
        end
      end

      def ret_service_name_from_raw_content(content)
        content.each_line do |line|
          if line_match = line.match(/(^name:)(.*)/)
            return line_match[2].strip
          end
        end
      end

      # opts can have keys
      #   :dir_path
      def set_base_dsl_file_obj!(opts = {})
        opts[:flag] = @flag
        @base_dsl_file_obj = self.class.base_dsl_file_obj(opts)
      end

      # opts can have keys
      #   :dir_path
      def  self.base_dsl_file_obj(opts = {}) 
        opts[:flag] = false if opts[:flag].nil?
        DirectoryParser.matching_file_obj?(FILE_TYPES, opts)
      end
      FILE_TYPES = 
        [
         ::DTK::DSL::FileType::CommonModule::DSLFile::Top,
         ::DTK::DSL::FileType::ServiceInstance::DSLFile::Top,
         ::DTK::DSL::FileType::ServiceInstance::DSLFile::Top::Hidden
        ]

      def module_ref_object_from_options_or_context?(options, module_refs_opts = {})
        # using :ignore_parsing_errors to ret namespace, name and version from .yaml file even if there are parsing errors
        @options.merge!(:ignore_parsing_errors => module_refs_opts[:ignore_parsing_errors])

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

      def service_instance_in_options_or_context(options, service_refs_opts = {})
        service_instance_in_options_or_context?(options, service_refs_opts) || raise_error_when_missing_context(:service_instance, options)
      end
      
      def service_instance_in_options_or_context?(options, service_refs_opts = {})
        # using :ignore_parsing_errors to ret namespace, name and version from .yaml file even if there are parsing errors
        @options.merge!(:ignore_parsing_errors => service_refs_opts[:ignore_parsing_errors])

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
        :module_ref       => 'module'
      }
      def raise_error_when_missing_context(type, options = {})
        if options["d"].nil?
          @base_dsl_file_obj.raise_error_if_no_content
        else
          @base_dsl_file_obj.raise_error_if_no_content_flag(type)
        end
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
