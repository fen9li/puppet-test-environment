class profile::ruby {

  # install ruby from rvm
  class { '::rvm': } 
  
  # To use rvm without sudo, add user 'fli' to the rvm group
  rvm::system_user { fli: ; }

  # install ruby 2.4 and set it as default version
  rvm_system_ruby {
    'ruby-2.4':
      ensure      => 'present',
      default_use => true;
  }
}
