class profile::base {

  # Create user 'centos'
  group { 'centos':
    ensure => 'present',
    gid    => 3000,
  }

  user { 'centos':
    ensure           => 'present',
    comment          => 'Standard user',
    gid              => 3000,
    groups           => ['centos'],
    home             => '/home/centos',
    managehome       => 'true',
    shell            => '/bin/bash',
    uid              => 3000,
  }

  ssh_authorized_key { 'centos@feng9.li':
    ensure => present,
    user   => 'centos',
    type   => 'ssh-rsa',
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDHRRnHHiUgkdyK6FFJTSLxOFf8X2MYskgaKnXCwoU5C0bAIN8xUwcsf4+pA8sIwLl85HZQaNP1Gi1QM0ILOpUgl6rKCFFVSIp/Z+DPJYmT9aI1z3V4Nr6ELZ+gxxEIWyXqMWV19Z4ygE4ZntGLr23EYx2tO//lAazSnaRdO2/STww0cTxSwOJn0FOJs8WgGN7mZM9g8rWCyHKIN2BwDoyXm3ALcEm2bBzyAeuGZj1TNjHFXvLNqj+6HlNr/MaFPoyBoOrH1zN0sQVc88//C5WrZlUJCVN+/H+MhQm08T4QdxqK2haQ62PZCVUqJGV3NBW6fZGRpqjEfulSfc9kSXTH',
  } 

  # Disable ssh password login
  augeas { "sshd_config":
    notify  => Service['sshd'], # restart sshd service
    context => "/files/etc/ssh/sshd_config",
    changes => [
      "set PasswordAuthentication no",
      "set PermitRootLogin no",
    ],
  }

  service { 'sshd':
    ensure     => running,
    enable     => true,
  }

}
