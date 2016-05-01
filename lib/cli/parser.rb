module DTK::CLI
  # Delegation module for wrapping third party library used to do parsing
  class Parser
    module Plugin
      DEFAULT = :gli
      DEFAULT_CLASS_NAME = "#{DEFAULT.to_s.capitalize}"
      # autoload DEFAULT_CLASS_NAME.to_sym, "plugin/#{DEFAULT_PLUGIN}"
      require_relative "parser/plugin/#{DEFAULT}"
      def self.default_class
        const_get DEFAULT_CLASS_NAME
      end
    end

    module Methods
      def self.all
        [:arg_name, :arg_name, :command, :default_value, :desc, :flag, :switch, :run, :add_command_defaults!]
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




