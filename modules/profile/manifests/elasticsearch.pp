class profile::elasticsearch (
  String $instance_name,
){

  class { 'elasticsearch':
    java_install => true,
    manage_repo  => true,
    repo_version => '5.x',
    restart_on_change => true,

    # setup REST API
    api_protocol            => 'http',
    api_host                => 'localhost',
    api_port                => 9200,
    api_timeout             => 10,
    api_basic_auth_username => undef,
    api_basic_auth_password => undef,
    api_ca_file             => undef,
    api_ca_path             => undef,
    validate_tls            => true,

    jvm_options => ['-Xms1g','-Xmx1g'],

    datadir => '/var/lib/fli-test',

    config => {
      'cluster.name' => 'fli-test',
      'indices.store.throttle.max_bytes_per_sec' => '15mb',

      'discovery.zen.ping.unicast.hosts' => "192.168.224.41, 192.168.224.42",
      'discovery.zen.minimum_master_nodes' => 1
    },

    # configure elaseticsearch instances
    # the node name will be set to $hostname-$instance_name
    instances => {
      $instance_name => {
        'config' => {
          'cluster.name' => 'fli-test',
          'node.master' => true,
          'node.data' => true,
          'network.host' => [$facts['fqdn'],_local_],
          'transport.host' => $facts['networking']['interfaces']['ens35']['ip']
        }
      }
    }
  }

  # create elasticsearch yum repo
  $es_yum_repo_file = 
"[elasticsearch-5.x]
name=Elasticsearch repository for 5.x packages
baseurl=https://artifacts.elastic.co/packages/5.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
"

  file { '/etc/yum.repos.d/elasticsearch.repo':
    ensure => 'file',
    content => $es_yum_repo_file,
  }

}

