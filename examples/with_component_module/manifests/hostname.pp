class host::hostname(
 $hostname = undef,
 $append_node_group_index = true
)
{

  if $hostname == undef {
    $base_name = $::dtk_assembly_node_base_name
  } else {
    $base_name = $hostname
  }

  if "${append_node_group_index}" == 'true' and $::dtk_assembly_node_type == 'node_group_member' and $::dtk_assembly_node_index != '' {
    $new_hostname = "${base_name}-${::dtk_assembly_node_index}"
  } else {
    $new_hostname = $base_name
  }

  file { '/etc/hostname':
        ensure  => present,
        content => "${new_hostname}\n"
  }

  exec { "hostname ${new_hostname}":
    path => ['/bin']
  }

  host::hostname::set_hosts{ $new_hostname: }
} 

define host::hostname::set_hosts() {
  $new_hostname = $name
  $new_hostname_with_domain = "${$new_hostname}.${::domain}" 

  if $::hostname != $new_hostname and $::hostname != $new_hostname_with_domain {
    host { $::hostname:
      ensure => 'absent'
    }
  }
  if $::fqdn != $new_hostname and $::fqdn != $new_hostname_with_domain and $::hostname != $::fqdn {
    host { $::fqdn:
      ensure => 'absent'
    }
  }
  # important for to make $new_hostname_with_domain and not $new_hostname primary
  host { $new_hostname:
    ensure => 'absent'
  } -> 
  host { $new_hostname_with_domain:
    ensure       => 'present',
    host_aliases => [$new_hostname],
    ip           => $::ipaddress_eth0
  }
} 
