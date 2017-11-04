class role::webserver {
  include profile::chrony
  include profile::apache
}
