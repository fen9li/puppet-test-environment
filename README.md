# Puppet's Way to Infrastructure as Code

Infrastructure as code is the practice of treating infrastructure as if it were code — which gives it power to apply software practices such as version control, peer review, automated testing, release tagging, release promotion, and continuous delivery.
This project demos how Puppet can be used for this purpose. 

  - Puppet Server 5.3.2 - newest version at the time of writing
  - Github based
  - Make full use of published general purpose Puppet modules - dont re invent the wheel
  - Architected on Puppet roles and profiles
  - Ready to use solution to provision multi-nodes ElasticSearch cluster
  - A skeleton solution to provision Apache Webserver vHosts

## Target Demo Infrastructure 
To demo how to build an enterprise infrastructure environment by using Puppet, this project will privision a two-nodes ElasticSearch Cluster and a two-vhosts Apache Webserver.

### ElasticSearch Cluster (2 physical / virtual nodes, each runs an ElasticSearch instance.)

| Hostname 		| esnode41.fen9.li      | esnode42.fen9.li      | 
| :---                  | :---                  | :---          	|
| Configuration(Note 1)	| 2 vCPU, 2GiB RAM, 2 NICs, 30GiB disk space 	| 2 vCPU, 2GiB RAM, 2 NICs, 30GiB disk space |
| Role			| es master & data node | es master & data node |
| NIC ens33 IP address - External / REST Traffic(Note 2)	| 192.168.200.41/24  | 192.168.200.42/24	|
| Default Gateway					| 192.168.200.2	     | 192.168.200.2    	|
| NIC ens35 IP address - Cluster Traffic(Note 2)		| 192.168.224.41/24  | 192.168.224.42/24	|	

>Note

>1/ Listing configuration is for reference only. Please reference how many GiB RAM you have here when you configure the Java heapsize later.

>2/ Each node has 2 NICs sitting in separate subnets. One subnet is for external / REST traffic and another is for Internal / Cluster traffic. The hostname, networking are supposed to configure during provisioning, thus wont be covered by Puppet.

### Apache Webserver ( 2 vhosts in this example)

| Webserver / vhostname | Physical Host         | Expose port   |
| :---                  | :---                  | :---          |
| first.fen9.li         | test31.fen9.li        | 80/tcp        |
| second.fen9.li        | test31.fen9.li        | 80/tcp        |

## How it works

  - On Puppet server
    * Git clone demo Puppet codes to create a new 'puppet_test_environment'
    * Install required Puppet modules from [Puppet Forge](https://forge.puppet.com/)
    * Update site.pp accordingly
  - On Puppet agent
    * Run 'puppet agent --test --environment puppet_test_environment'

## Resources required in this solution
  - A Linux host/instance acts as Puppet Server
  - Linux hosts/instances act(s) as Puppet Agent

> Modify below accordingly to your own environment.

| hostname              | IP address            | Role          |
| :---                  | :---                  | :---          |
| puppet.fen9.li        | 192.168.200.70/24     | Puppet Server |
| esnode41.fen9.li      | 192.168.200.41/24     | Puppet Agent  |
| esnode42.fen9.li      | 192.168.200.42/24     | Puppet Agent  |
| test31.fen9.li        | 192.168.200.31/24     | Puppet Agent  |

## Github resources
  - A Github account
  - A Github repository for Puppet codes

## Usage

### Setup Puppet Server & Agent

* Install Puppet Server & Agent
> Install Puppet Server and Agent software as per [official instructions](https://puppet.com/docs/puppetserver/5.1/install_from_packages.html).

```sh
...
puppet ~]# for i in puppet hiera; do $i --version; done
5.3.2
3.4.2
puppet ~]#

...
esnode41 ~]# puppet --version
5.3.2
esnode41 ~]#
...
```

* Configure Certification Between Pupper Server and Agent
> Ensure communication between Puppet Server and Agent

```sh
esnode41 ~]# puppet agent --test
Info: Caching certificate for esnode41.fen9.li
Info: Caching certificate_revocation_list for ca
Info: Caching certificate for esnode41.fen9.li
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Caching catalog for esnode41.fen9.li
Info: Applying configuration version '1509447198'
Notice: Applied catalog in 0.02 seconds
esnode41 ~]#
```

### On Puppet Server
* Change directory to '/etc/puppetlabs/code/environments' and git clone Puppet codes

```sh
puppet environments]# pwd
/etc/puppetlabs/code/environments
puppet environments]#

[root@puppet environments]# git clone --branch develop https://github.com/fen9li/puppet_test_environment.git
Cloning into 'puppet_test_environment'...
remote: Counting objects: 158, done.
remote: Compressing objects: 100% (99/99), done.
remote: Total 158 (delta 52), reused 127 (delta 28), pack-reused 0
Receiving objects: 100% (158/158), 21.85 KiB | 0 bytes/s, done.
Resolving deltas: 100% (52/52), done.
[root@puppet environments]#
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
│   ├── groups
│   │   ├── elasticsearchnode-puppet_test_environment.yaml
│   │   ├── elasticsearchnode-test.yaml
│   │   ├── webserver-puppet_test_environment.yaml
│   │   └── webserver-test.yaml
│   └── nodes
│       ├── esnode41.fen9.li.yaml
│       └── esnode42.fen9.li.yaml
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
│   │       ├── elasticsearch.pp
│   │       └── firewalld.pp
│   └── role
│       └── manifests
│           ├── elasticsearchnode.pp
│           └── webserver.pp
└── README.md

12 directories, 18 files
puppet environments]#
```

* Install and double check required general purpose Puppet modules

```sh
puppet environments]# puppet module install puppetlabs-stdlib --version 4.21.0 --target-dir /etc/puppetlabs/code/modules
...
puppet environments]# puppet module install puppetlabs-concat --version 4.1.0 --target-dir /etc/puppetlabs/code/modules
...
puppet environments]# puppet module install aboe-chrony --version 0.1.2 --target-dir /etc/puppetlabs/code/modules
...
puppet environments]# puppet module install puppetlabs-apache --version 2.3.0 --target-dir /etc/puppetlabs/code/modules
...
puppet environments]# puppet module install crayfishx-firewalld --version 3.4.0 --target-dir /etc/puppetlabs/code/modules
...
puppet environments]# puppet module install elastic-elasticsearch --version 5.4.3 --target-dir /etc/puppetlabs/code/modules

...
[root@puppet modules]# pwd
/etc/puppetlabs/code/modules
[root@puppet modules]#

[root@puppet modules]# ls -lZ
drwxr-xr-x. root root unconfined_u:object_r:usr_t:s0   apache
drwxr-xr-x. root root unconfined_u:object_r:usr_t:s0   apt
drwxr-xr-x. root root unconfined_u:object_r:usr_t:s0   archive
drwxr-xr-x. root root unconfined_u:object_r:usr_t:s0   chrony
drwxr-xr-x. root root unconfined_u:object_r:usr_t:s0   concat
drwxr-xr-x. root root unconfined_u:object_r:usr_t:s0   datacat
drwxr-xr-x. root root unconfined_u:object_r:usr_t:s0   elasticsearch
drwxr-xr-x. root root unconfined_u:object_r:usr_t:s0   firewalld
drwxr-xr-x. root root unconfined_u:object_r:usr_t:s0   java
drwxr-xr-x. root root unconfined_u:object_r:usr_t:s0   stdlib
drwxr-xr-x. root root unconfined_u:object_r:usr_t:s0   yum
[root@puppet modules]#

```

## Create Demo Enterprise Infrastructure

### Update site.pp

```sh
puppet puppet_test_environment]# pwd
/etc/puppetlabs/code/environments/puppet_test_environment
[root@puppet puppet_test_environment]# cat manifests/site.pp
node 'test31.fen9.li' {
  include role::webserver
}

node /esnode4[1-9].fen9.li/ {
  include role::elasticsearchnode
}
puppet puppet_test_environment]#

```

### Apply Catalog on esnode4x.fen9.li
> If esnode4x.fen9.li is a brand new Linux host setup, then you may have to apply catalog twice.

```sh
esnode41 ~]# puppet agent  --test --environment puppet_test_environment
...
esnode41 ~]#
...
esnode42 ~]# puppet agent  --test --environment puppet_test_environment
...
esnode42 ~]#
```

### Apply Catalog on test31.fen9.li
> If test31.fen9.li is a brand new Linux host setup, then you may have to apply catalog twice.

```sh
test31 ~]# puppet agent --environment puppet_test_environment --test
...
test31 ~]#
```

### Test New Demo Infrasturcture
Testing can be done by following normal practice.

## Where To Go Next
* Conbine AWS cloudformation, code deploy and Puppet to create a real AWS-based infrasturcture-as-code environment.
