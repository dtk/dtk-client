module DTK::CLI
  # Delegation module for wrapping third party library used to do parsing
  module Parser
    SELECTED_PLUGIN = :gli
    
    module Plugin
      # autoload "#{SELECTED_PLUGIN.capitalize}".to_sym, "plugin/#{SELECTED_PLUGIN}"
      require_relative "parser/plugin/#{SELECTED_PLUGIN}"
    end
    SELECTED_PLUGIN_MODULE = Plugin.const_get "#{SELECTED_PLUGIN.to_s.capitalize}"
    include SELECTED_PLUGIN_MODULE
  end
end

=begin
 TODO: think only way to do this is to have parser
as an object in command_context
  module DTK::CLI
    class CommandContex
      def initialize
        @parser = Parser.new 
      end
    end
   end
    module Methods
      def self.direct_delegation
        [:program_desc, :version, :subcommand_option_handling, :arguments, :desc, :switch, :default_value, :arg_name]
      end
      def self.mediated
        [:assert_defaults]
      end
    end

    def method_missing(method, *args, &body)
pp [self, method, args]
      if Methods.direct_delegation.include?(method)
        plugin_delegation_module.send(method, *args, &body) 
      elsif Methods.mediated.include?(method)
        plugin_clas.send(method, *args, &body)
      else
        super
      end
    end
    
    def respond_to?(method)
      all_parser_methods.include?(method) or super
    end

    private
    
    def all_parser_methods
      @@all_parser_methods ||= Methods.direct_delegation + Methods.mediated
    end
    
    def plugin_delegation_module
      SELECTED_PLUGIN_MODULE
    end

    def plugin_module
      SELECTED_PLUGIN_MODULE
    end
    
  end
end
=end



