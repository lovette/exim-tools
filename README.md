# exim-tools

A collection of tools for the [Exim Mail Transfer Agent](http://www.exim.org/)


Tools
---
* [exim-hup](https://github.com/lovette/exim-tools/tree/master/exim-hup)
* [exim-minify-conf](https://github.com/lovette/exim-tools/tree/master/exim-minify-conf)
* [exim-run-acl-tests](https://github.com/lovette/exim-tools/tree/master/exim-run-acl-tests)
* [exim-test-session](https://github.com/lovette/exim-tools/tree/master/exim-test-session)
* [exim-tidyall](https://github.com/lovette/exim-tools/tree/master/exim-tidyall)


Requirements
---

* [Exim 4 or later](http://www.exim.org/)
* [BASH 3.0 or later](http://www.gnu.org/software/bash/)


Installation
---
Download the archive and extract into a folder. Then, to install the package:

	make install

This installs admin scripts to `/usr/sbin`, user scripts to `/usr/local/bin` and
man pages to `/usr/share/man`. You can also stage the installation with:

	make DESTDIR=/stage/path install

You can undo the install with:

	make uninstall
