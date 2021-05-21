make_ovip_sweeper
=================

* ***This repository is archived***
* ***No longer maintained***

Description
-----------

Generate safety sweeper script for the NNM topology.  
That contains reports of relationships with other interfaces.

Usage
-----

```shell
$ cat ./del_ipaddrs.txt
192.168.1.1
192.168.255.254
```

```shell
$ make_ovip_sweeper.sh < del_ipaddrs.txt > ./del_ovtopology.sh
$ chmod 744 ./del_ovtopology.sh
$ more ./del_ovtopology.sh
$ ./del_ovtopology.sh
```

Requirements
------------

* Bourne Shell Family
* NetworkNodeManager(OpenView) - 7.n
* perl - 5.8.n

License
-------

The 2-clause BSD license

Copyright (c) 2011-2012 Kenichi Kamiya

See the file LICENSE for further details.
