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
module DTK::CLI
  class CommandContext
    require_relative('command_context/all')
    ALL_CONTEXTS = [:service, :module]
    ALL_CONTEXTS.each { |context| require_relative("command_context/#{context}") }

    def initialize
      @parser = Parser.default
      add_command_defaults!
      add_command_defs!
    end
    private :initialize 

    def self.determine_context
      get_and_set_cache { create_when_in_specific_context? || create_default }
    end

    def run(argv)
      @parser.run(argv)
    end
    
    def method_missing(method, *args, &body)
      parser_object_methods.include?(method) ? @parser.send(method, *args, &body) : super
    end
    
    def respond_to?(method)
      parser_object_methods.include?(method) or super
    end
    
    private

    def self.create_default
#      All.new
      Module.new
    end

    def parser_object_methods
      @@parser_object_methods ||= Parser::Methods.all 
    end
    
    def self.get_and_set_cache
      # TODO: stub
      yield
    end
      
    def self.create_when_in_specific_context?
      # TODO: stub 
      nil
    end

    # Can be ovewritten
    def add_command_defs!
      add_specified_command_defs!(context_name)
    end

    def add_specified_command_defs!(context_name)
      send("add_command_defs__#{context_name}!".to_sym)
    end

    def context_name
      @context_name ||= self.class.to_s.split('::').last.downcase
    end

    def all_context_names
      @@all_context_names ||= ALL_CONTEXTS
    end

  end
end
