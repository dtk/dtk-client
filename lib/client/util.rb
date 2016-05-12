module DTK
  require_relative 'util/error'
  require_relative 'util/post_body'
  require_relative 'util/auxiliary'
  # auxiliary must be before os_util
  require_relative 'util/os_util'
  require_relative 'util/ssh_util'
  require_relative 'util/console'
  require_relative 'util/disk_cacher'
end
