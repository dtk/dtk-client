module DTK::CLI
  class CommandContext
    class All < self
      private

      def add_command_defs!
        all_context_names.each { |context_name| add_specified_command_defs!(context_name) }
      end
    end
  end
end
