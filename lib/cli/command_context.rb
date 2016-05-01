module DTK::CLI
  class CommandContext
    require_relative('command_context/all')
    require_relative('command_context/service')
    require_relative('command_context/module')

    include Parser

    def self.determine_context
      create_when_in_specific_context? || create_default
    end

    private
    
    def self.create_when_in_specific_context?
      # TODO: stub 
      nil
    end

    def self.create_default
      All.new
    end
  end
end
