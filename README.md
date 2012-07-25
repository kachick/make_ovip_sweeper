make_ovip_sweeper
=================

* [code](http://github.com/kachick/make_ovip_sweeper)
* [bugs](http://github.com/kachick/make_ovip_sweeper/issues)

Description
-----------

Generate safety sweeper commands for the NNM topology.
That contains reports of relationships with other interfaces.

Usage
-----

    make_ovip_sweeper.sh < del_ipaddrs.txt > ./del_ovtopology.sh
    chmod 744 ./del_ovtopo.sh

del_ipaddrs.txt

    192.168.1.1
    192.168.255.254

Requirements
------------

* NNM(NetworkNodeManager OpenView) - 7.5n
* Bourne Shell Family
* perl - 5.8.n

== License

The 2-clause BSD license

Copyright (c) 2011-2012 Kenichi Kamiya

See the file LICENSE for further details.
