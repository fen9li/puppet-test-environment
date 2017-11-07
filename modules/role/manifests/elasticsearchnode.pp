class role::elasticsearchnode {
  include profile::chrony
  include profile::elasticsearch
  include profile::firewalld
}
