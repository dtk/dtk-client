module DTK::CLI
  # Top-level entry class
  class Runner
    def self.run(argv)
      command_context = CommandContext.determine_context
      command_context.run(argv)
    end
  end
end
