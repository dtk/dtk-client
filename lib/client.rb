module DTK
  module Client
    require_relative 'client/util'
    # util must be loaded first
    require_relative 'client/error'
    require_relative 'client/logger'
    require_relative 'client/configurator'
    require_relative 'client/response'
    require_relative 'client/conn'
    require_relative 'client/session'
    require_relative 'client/config'
    require_relative 'client/operation'
    require_relative 'client/render'
  end
end
