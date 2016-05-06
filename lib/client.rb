module DTK
  module Client
    require_relative 'client/ssh_util'
    require_relative 'client/auxiliary'
    # auxiliary must be for os_util
    require_relative 'client/os_util'
    # os_util must be before configurator
    require_relative 'client/configurator'
    require_relative 'client/configuration'
  end
end
