require 'pp'
module DTK
  module CLI
    require_relative 'cli/version'
    require_relative 'cli/runner'
    require_relative 'cli/processor'
    require_relative 'cli/command'
    # processor and command must go before context
    require_relative 'cli/context'
  end
end
