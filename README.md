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

| Hostname              | esnode41.fen9.li      | esnode42.fen9.li      |
| :---                  | :---                  | :---                  |
| Configuration(Note 1) | 2 vCPU, 2GiB RAM, 2 NICs, 30GiB disk space    | 2 vCPU, 2GiB RAM, 2 NICs, 30GiB disk space |
| Role                  | es master & data node | es master & data node |
| NIC ens33 IP address - External / REST Traffic(Note 2)        | 192.168.200.41/24  | 192.168.200.42/24        |
| Default Gateway                                       | 192.168.200.2      | 192.168.200.2            |
| NIC ens35 IP address - Cluster Traffic(Note 2)                | 192.168.224.41/24  | 192.168.224.42/24        |

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

puppet environments]# git clone --branch develop https://github.com/fen9li/puppet_test_environment.git
Cloning into 'puppet_test_environment'...
remote: Counting objects: 158, done.
remote: Compressing objects: 100% (99/99), done.
remote: Total 158 (delta 52), reused 127 (delta 28), pack-reused 0
Receiving objects: 100% (158/158), 21.85 KiB | 0 bytes/s, done.
Resolving deltas: 100% (52/52), done.
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
puppet modules]# pwd
/etc/puppetlabs/code/modules
puppet modules]#

puppet modules]# ls -lZ
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
puppet modules]#

```

## Create Demo Enterprise Infrastructure

### Update site.pp

```sh
puppet puppet_test_environment]# pwd
/etc/puppetlabs/code/environments/puppet_test_environment
puppet puppet_test_environment]# cat manifests/site.pp
node 'test31.fen9.li' {
  include role::webserver
}

node /esnode4[1-9].fen9.li/ {
  include role::elasticsearchnode
}
puppet puppet_test_environment]#

```

### Apply Catalog on esnode4x.fen9.li & test31.fen9.li
> If esnode4x.fen9.li & test31.fen9.li are brand new Linux host setups, then you may have to apply catalog twice.

> The safest way to apply catalog is keep running command 'puppet agent  --test --environment puppet_test_environment' until you dont see any changes apply. 

> Do the same with esnode42.fen9.li & test31.fen9.li.

```sh
esnode41 ~]# puppet agent  --test --environment puppet_test_environment
...
esnode41 ~]# puppet agent  --test --environment puppet_test_environment
Info: Using configured environment 'puppet_test_environment'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Loading facts
Info: Caching catalog for esnode41.fen9.li
Info: Applying configuration version '1510117138'
Notice: Applied catalog in 1.79 seconds
esnode41 ~]#
```

## Test New Demo Infrasturcture
### Testing ElasticSearch Cluster

* Check out elasticsearch service status, configuration files (listing only esnode41.fen9.li below)
  
```sh
esnode41 ~]# systemctl status elasticsearch-es-01
● elasticsearch-es-01.service - Elasticsearch instance es-01
   Loaded: loaded (/usr/lib/systemd/system/elasticsearch-es-01.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2017-11-08 14:44:47 AEDT; 2min 2s ago
     Docs: http://www.elastic.co
 Main PID: 1846 (java)
   CGroup: /system.slice/elasticsearch-es-01.service
           └─1846 /bin/java -Dfile.encoding=UTF-8 -Dio.netty.noKeySetOptimiza...

Nov 08 14:44:47 esnode41.fen9.li systemd[1]: Starting Elasticsearch instance....
Nov 08 14:44:47 esnode41.fen9.li systemd[1]: Started Elasticsearch instance ....
Nov 08 14:44:54 esnode41.fen9.li elasticsearch[1846]: [2017-11-08T14:44:53,92...
Hint: Some lines were ellipsized, use -l to show in full.
esnode41 ~]# 
esnode41 ~]# cat /etc/elasticsearch/es-01/elasticsearch.yml
### MANAGED BY PUPPET ###
---
cluster.name: fli-test
discovery.zen.minimum_master_nodes: 2
discovery.zen.ping.unicast.hosts: 192.168.224.41, 192.168.224.42
indices.store.throttle.max_bytes_per_sec: 15mb
network.host:
- esnode41.fen9.li
- _local_
node.data: true
node.master: true
node.name: esnode41-es-01
path.data: "/var/lib/fli-test/es-01"
path.logs: "/var/log/elasticsearch/es-01"
transport.host: 192.168.224.41

esnode41 ~]#
esnode41 ~]# grep 1g /etc/elasticsearch/es-01/jvm.options
-Xms1g
-Xmx1g
esnode41 ~]#

```

* Check out elasticsearch cluster status

```sh
esnode41 ~]# curl localhost:9200
{
  "name" : "esnode41-es-01",
  "cluster_name" : "fli-test",
  "cluster_uuid" : "xJRm74RHQtKs4O0_bVMPuw",
  "version" : {
    "number" : "5.6.4",
    "build_hash" : "8bbedf5",
    "build_date" : "2017-10-31T18:55:38.105Z",
    "build_snapshot" : false,
    "lucene_version" : "6.6.1"
  },
  "tagline" : "You Know, for Search"
}
esnode41 ~]# curl esnode41:9200
{
  "name" : "esnode41-es-01",
  "cluster_name" : "fli-test",
  "cluster_uuid" : "xJRm74RHQtKs4O0_bVMPuw",
  "version" : {
    "number" : "5.6.4",
    "build_hash" : "8bbedf5",
    "build_date" : "2017-10-31T18:55:38.105Z",
    "build_snapshot" : false,
    "lucene_version" : "6.6.1"
  },
  "tagline" : "You Know, for Search"
}
esnode41 ~]# curl esnode42:9200
{
  "name" : "esnode42-es-02",
  "cluster_name" : "fli-test",
  "cluster_uuid" : "xJRm74RHQtKs4O0_bVMPuw",
  "version" : {
    "number" : "5.6.4",
    "build_hash" : "8bbedf5",
    "build_date" : "2017-10-31T18:55:38.105Z",
    "build_snapshot" : false,
    "lucene_version" : "6.6.1"
  },
  "tagline" : "You Know, for Search"
}
esnode41 ~]#

esnode41 ~]# curl localhost:9200/_cluster/state/master_node,nodes?pretty
{
  "cluster_name" : "fli-test",
  "master_node" : "UfeEFufuRduuAWck75ZCzQ",
  "nodes" : {
    "UfeEFufuRduuAWck75ZCzQ" : {
      "name" : "esnode41-es-01",
      "ephemeral_id" : "50zc6BHzR3aFPg1Iaqkv5g",
      "transport_address" : "192.168.224.41:9300",
      "attributes" : { }
    },
    "TYNmcKzhRQ-u0eJaN3djCA" : {
      "name" : "esnode42-es-02",
      "ephemeral_id" : "oN92ojxSSbK6uaWppH8Ksw",
      "transport_address" : "192.168.224.42:9300",
      "attributes" : { }
    }
  }
}
esnode41 ~]#

esnode41 ~]# curl localhost:9200/_cat/health
1510113302 14:55:02 fli-test green 2 2 0 0 0 0 0 0 - 100.0%
esnode41 ~]#

esnode41 ~]# curl localhost:9200/_cat/nodes
192.168.224.41 12 94 2 0.00 0.08 0.13 mdi * esnode41-es-01
192.168.224.42 13 92 1 0.00 0.07 0.11 mdi - esnode42-es-02
esnode41 ~]#

```

### Testing Apache Webserver

```sh
puppet test]# tail -n 3 /etc/hosts
192.168.200.31  test31.fen9.li   test31
192.168.200.31 first.fen9.li first
192.168.200.31 second.fen9.li second
puppet test]#

puppet test]# curl -i first.fen9.li
HTTP/1.1 200 OK
Date: Wed, 08 Nov 2017 03:30:57 GMT
Server: Apache/2.4.6 (CentOS)
Last-Modified: Wed, 08 Nov 2017 03:27:48 GMT
ETag: "1d-55d70458e1a44"
Accept-Ranges: bytes
Content-Length: 29
Content-Type: text/html

wulala from first.fen9.li...
puppet test]# curl -i second.fen9.li
HTTP/1.1 200 OK
Date: Wed, 08 Nov 2017 03:31:06 GMT
Server: Apache/2.4.6 (CentOS)
Last-Modified: Wed, 08 Nov 2017 03:27:48 GMT
ETag: "1e-55d70458e4d0c"
Accept-Ranges: bytes
Content-Length: 30
Content-Type: text/html

hulala from second.fen9.li...
puppet test]#
```

## Where To Go Next
* Conbine AWS cloudformation, code deploy and Puppet to create a real AWS-based infrasturcture-as-code environment.
