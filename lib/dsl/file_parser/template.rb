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
module DTK::DSL
  class FileParser                   
    class Template
      require_relative('template/constant_class_mixin')
      require_relative('template/parsing_error')
      require_relative('template/loader')

      # opts can have keys
      #   :file_obj
      #   :parent_key
      def initialize(raw_input, opts = {})
        @input      = Input.create(raw_input)
        @output     = empty_output(@input)
        @file_obj   = opts[:file_obj]
        @parent_key = opts[:parent_key]
      end
      
      def self.template_class(parse_template_type, dsl_version)
        Loader.template_class(parse_template_type, :dsl_version => dsl_version)
      end
      
      def parse
        parse!
        # return @output
        @output
      end

      private

      # Main parse call; Each concrete class should over write this
      def parse!
        raise Error::NoMethodForConcreteClass.new(self.class)
      end

      # The method output_type can be set on concrete class; it wil be set if input and output types are different
      def output_type
        nil
      end

      def empty_output(input)
        if output_type 
          Output.create(:output_type => output_type)
        else
          Output.create(:input => input)
        end
      end
      
      # args can have form 
      #  (:PasringErrorName,*parsing_error_params) or
      #  (parsing_error_params)
      def parsing_error(*args)
        if error_class = parsing_error_class?(args)
          error_params = args[1..args.size-1]
          error_class.new(*error_params, :file_obj => @file_obj, :qualified_key => @parent_key)
        else
          ParsingError.new(*args, :file_obj => @file_obj, :qualified_key => @parent_key)
        end
      end

      def parsing_error_class?(args)
        if args.first.kind_of?(Symbol)
          begin
            ParsingError.const_get(args.first.to_s)
          rescue
            nil
          end
        elsif args.first.kind_of?(ParsingError)
          args.first
        end
      end

      # opts can have keys
      #  :parent_key
      def parse_child(parse_template_type, input, opts = {})
        parser_class = Loader.template_class(parse_template_type, :template_version => template_version)
        parser_class.new(input, opts.merge(:file_obj => @file_obj)).parse
      end

      def parent_key?(index = nil)
        if @parent_key
          index ? "#{@parent_key}[#{index}]" : parent_key
        end
      end

      def input_hash
        @input_hash ||= @input.kind_of?(Input::Hash) ? @input : raise_input_error(::Hash)
      end

      def input_array
        @input_array = @input.kind_of?(Input::Array) ? @input : raise_input_error(::Array)
      end

      def input_string
        @input_string ||= @input.kind_of?(::String) ? @input : raise_input_error(::String)
      end

      def raise_input_error(correct_ruby_type)
        raise parsing_error(:WrongObjectType, @input, correct_ruby_type)
      end

      def constant_matches(object, constant)
        constant_class.matches?(object, constant) || raise_missing_key_value(constant)
      end

      def raise_missing_key_value(constant)
        key = constant_class.canonical_value(constant)
        raise parsing_error(:MissingKeyValue, key)
      end
      
      def constant_class
        self.class::Constant
      end
    end
  end
end

