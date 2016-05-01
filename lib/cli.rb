require 'pp'
module DTK
  module CLI
    require_relative 'cli/version'
    require_relative 'cli/runner'
    require_relative 'cli/parser'
    # parser must go before command_context
    require_relative 'cli/command_context'
  end
end
