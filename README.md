# Build 2 Apache Webserver vHOSTs in One Linux Host by Using Puppet - Infrastructure as Code

Infrastructure as code is the practice of treating infrastructure as if it were code — this gives power to apply software practices such aas version control, peer review, automated testing, release tagging, release promotion, and continuous delivery. 
This project demos a solution to build 2 Apache vHOSTs upon a Linux host by using most updated Puppet practices.

  - Puppet Server 5.3.2
  - Github based
  - Puppet roles and profiles built upon existing Puppet modules

# Purpose of this project
Build 2 Apache Webserver vhosts as per below defination by using Puppet.

| Webserver / vhostname	| Physical Host		| Expose port	| 
| :---			| :---			| :---		|
| first.fen9.li		| test31.fen9.li	| 80		|
| second.fen9.li	| test31.fen9.li	| 80		| 

# How it works
  
  - On Puppet server
    Git clone Puppet code to create a new puppet_test_environment
    Install required Puppet modules in puppet_test_environment 
    Update site.pp
  - On Puppet agent
    Run 'puppet agent --test --environment puppet_test_environment'

# Resources required in this solution
  - A Linux host/instance - Puppet Server
  - A Linux host/instance - Puppet Agent

# Github resources
  - A Github account 
  - A Github repository for Puppet codes

# Usage

## Setup Puppet Server & Agent

* The hostname, IP addresses etc

> Modify accordingly  as per your own environment.

| hostname		| IP address		| Role		|
| :---                  | :---                  | :---          |
| puppet.fen9.li	| 192.168.200.70/24	| Puppet Server |
| test31.fen9.li	| 192.168.200.31/24	| Puppet Agent	| 

* Install Puppet Server & Agent
> Install Puppet software as per official instructions.

```sh
...
puppet ~]# puppet --version
5.3.2
puppet ~]#

...
test31 ~]# puppet --version
5.3.2
test31 ~]#
...
``` 

* Configure and Setup Certification Between Pupper Server and Agent
> Ensure communication between Puppet Server and Agent

```sh
test31 ~]# puppet agent --test
Info: Caching certificate for test31.fen9.li
Info: Caching certificate_revocation_list for ca
Info: Caching certificate for test31.fen9.li
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Caching catalog for test31.fen9.li
Info: Applying configuration version '1509447198'
Notice: Applied catalog in 0.02 seconds
test31 ~]# 
```

## Create Apache Webserver
> The demo Puppet codes is kept in GitHub Repo 'https://github.com/fen9li/puppet-test-environment.git'.
> Please use features branch at this moment.

* git clone Puppet codes on puppet server

```sh
puppet environments]# pwd
/etc/puppetlabs/code/environments
puppet environments]#

puppet environments]# git clone --branch features https://github.com/fen9li/puppet_test_environment.git
Cloning into 'puppet_test_environment'...
remote: Counting objects: 74, done.
remote: Compressing objects: 100% (49/49), done.
remote: Total 74 (delta 14), reused 61 (delta 6), pack-reused 0
Unpacking objects: 100% (74/74), done.
puppet environments]#
``` 

* The files and directories structure would look like below ...

```sh
puppet environments]# pwd
/etc/puppetlabs/code/environments
puppet environments]#

puppet environments]# ls -lZ
drwxr-xr-x. root root system_u:object_r:puppet_etc_t:s0 production
drwxr-xr-x. root root unconfined_u:object_r:puppet_etc_t:s0 puppet_test_environment
puppet environments]#

puppet environments]# cd puppet_test_environment/
puppet puppet_test_environment]# tree
.
├── data
│   └── groups
│       └── webserver-test.yaml
├── environment.conf
├── hiera.yaml
├── manifests
│   └── site.pp
└── modules
    ├── flimodule
    │   └── lib
    │       └── facter
    │           ├── elor.rb
    │           └── vne.rb
    ├── profile
    │   └── manifests
    │       ├── apache.pp
    │       ├── chrony.pp
    │       └── firewalld.pp
    └── role
        └── manifests
            └── webserver.pp

11 directories, 10 files
puppet puppet-test-environment]#
```

* Install required Puppet Modules

```sh
puppet environments]# puppet module install aboe-chrony --version 0.1.2 --environment puppet_test_environment
puppet environments]# puppet module install puppetlabs-apache --version 2.3.0 --environment puppet_test_environment
puppet environments]# puppet module install crayfishx-firewalld --version 3.4.0 --environment puppet_test_environment
```

* Update site.pp
> Update site.pp as per your environment

```sh
puppet puppet_test_environment]# pwd
/etc/puppetlabs/code/environments/puppet_test_environment
puppet puppet_test_environment]# 

puppet puppet_test_environment]# cat manifests/site.pp
node 'test31.fen9.li' {
  include role::webserver
}
puppet puppet_test_environment]#
```

## Apply catalog on test31.fen9.li
```sh
test31 ~]# puppet agent --environment puppet_test_environment --test
...
test31 ~]# 
```

## Where to go next
* Add more features to Apache Server(s).
* Add more nodes for other purpose.
