class profile::apache {
  class {'::apache': }

  file { '/var/www/html/index.html':
    ensure   => 'file',
    content  => 'holy cow from first.fen9.li...',
  }

}
