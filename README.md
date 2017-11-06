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
    * Git clone Puppet code to create a new puppet_test_environment
    * Install required Puppet modules in puppet_test_environment 
    * Update site.pp
  - On Puppet agent
    * Run 'puppet agent --test --environment puppet_test_environment'

# Resources required in this solution
  - A Linux host/instance - Puppet Server
  - A Linux host/instance - Puppet Agent

> Modify accordingly  as per your own environment.

| hostname		| IP address		| Role		|
| :---                  | :---                  | :---          |
| puppet.fen9.li	| 192.168.200.70/24	| Puppet Server |
| test31.fen9.li	| 192.168.200.31/24	| Puppet Agent	| 


# Github resources
  - A Github account 
  - A Github repository for Puppet codes

# Usage

## Setup Puppet Server & Agent

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
puppet environments]# tree
.
├── data
│   └── groups
│       ├── webserver-puppet_test_environment.yaml
│       └── webserver-test.yaml
├── environment.conf
├── hiera.yaml
├── manifests
│   └── site.pp
├── modules
│   ├── flimodule
│   │   └── lib
│   │       └── facter
│   │           ├── elor.rb
│   │           └── vne.rb
│   ├── profile
│   │   └── manifests
│   │       ├── apache.pp
│   │       ├── chrony.pp
│   │       └── firewalld.pp
│   └── role
│       └── manifests
│           ├── elasticsearchnode.pp
│           └── webserver.pp
└── README.md

11 directories, 13 files
puppet environments]#
```

* Install required Puppet Modules

```sh
puppet environments]# puppet module install puppetlabs-stdlib --version 4.21.0 --target-dir /etc/puppetlabs/code/modules
puppet environments]# puppet module install puppetlabs-concat --version 4.1.0 --target-dir /etc/puppetlabs/code/modules
puppet environments]# puppet module install aboe-chrony --version 0.1.2 --target-dir /etc/puppetlabs/code/modules
puppet environments]# puppet module install puppetlabs-apache --version 2.3.0 --target-dir /etc/puppetlabs/code/modules
puppet environments]# puppet module install crayfishx-firewalld --version 3.4.0 --target-dir /etc/puppetlabs/code/modules
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
> If test31.fen9.li is a brand new Linux host setup, then you may have to apply catalog twice.

```sh
test31 ~]# puppet agent --environment puppet_test_environment --test
...
test31 ~]# 
```

## Test accessing webpages on 'first.fen9.li' & 'second.fen9.li' 
```sh
puppet ~]# grep test31.fen9.li /etc/hosts
192.168.200.31  test31.fen9.li   test31
puppet ~]#

puppet ~]# echo '192.168.200.31 first.fen9.li first' >> /etc/hosts  
puppet ~]# echo '192.168.200.31 second.fen9.li second' >> /etc/hosts
puppet ~]#

puppet ~]# curl -i first.fen9.li
HTTP/1.1 200 OK
Date: Mon, 06 Nov 2017 06:31:53 GMT
Server: Apache/2.4.6 (CentOS)
Last-Modified: Sun, 05 Nov 2017 23:56:31 GMT
ETag: "1c-55d45164ba193"
Accept-Ranges: bytes
Content-Length: 28
Content-Type: text/html

wulala from first.fen9.li...
puppet ~]#

puppet ~]# curl -i second.fen9.li
HTTP/1.1 200 OK
Date: Mon, 06 Nov 2017 06:32:01 GMT
Server: Apache/2.4.6 (CentOS)
Last-Modified: Sun, 05 Nov 2017 23:56:31 GMT
ETag: "1d-55d45164bc0ef"
Accept-Ranges: bytes
Content-Length: 29
Content-Type: text/html

hulala from second.fen9.li...
puppet ~]#
```

## Where to go next
* Conbine AWS cloudformation, code deploy and Puppet to create a real infrasturcture-as-code environment.
* Add more nodes for other purpose, such as elasticsearch cluster.
* Add more features to Apache Server(s), such as tls support.
