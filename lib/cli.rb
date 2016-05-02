require 'pp'
module DTK
  module CLI
    require_relative 'cli/version'
    require_relative 'cli/runner'
    require_relative 'cli/parser'
    require_relative 'cli/command'
    # parser and command must go before context
    require_relative 'cli/context'
  end
end
