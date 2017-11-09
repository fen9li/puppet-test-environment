class profile::base {

  file { '/etc/motd':
    ensure => file,
    source => "puppet:///modules/flimodule/motd.txt",
  }  

}
