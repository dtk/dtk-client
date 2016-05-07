module DTK
  module Client
    require_relative 'client/auxiliary'
    # auxiliary must be for os_util
    require_relative 'client/os_util'
    # os_util must be before configurator
    require_relative 'client/configurator'

    require_relative 'client/conn'
    require_relative 'client/ssh_util'
    require_relative 'client/session'
    require_relative 'client/config'
    require_relative 'client/error'
  end
end