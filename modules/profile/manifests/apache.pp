class profile::apache {

  class {'::apache': }

# define first.fen9.li vhost
  $first_html_index_content = 'wuwala from first.fen9.li...'

  apache::vhost { 'first.fen9.li':
    port    => '80',
    docroot => '/var/www/first',
  }

  file { '/var/www/first/index.html' :
    ensure   => 'file',
    content  => $first_html_index_content,
  }

# define second.fen9.li vhost
  $second_html_index_content = 'hulala from second.fen9.li...'

  apache::vhost { 'second.fen9.li':
    port    => '80',
    docroot => '/var/www/second',
  }

  file { '/var/www/second/index.html' :
    ensure   => 'file',
    content  => $second_html_index_content,
  }

}
