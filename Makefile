#!/usr/bin/make -f

SBINDIR = usr/sbin
LBINDIR = usr/local/bin
MANDIR = usr/share/man

all:

install:
	# Create directories
	install -d $(DESTDIR)/$(SBINDIR)
	install -d $(DESTDIR)/$(LBINDIR)
	install -d $(DESTDIR)/$(MANDIR)/man1
	install -d $(DESTDIR)/$(MANDIR)/man8

	# Install user scripts
	install -m 755 exim-run-acl-tests/exim-run-acl-tests.sh $(DESTDIR)/$(LBINDIR)/exim-run-acl-tests
	install -m 755 exim-test-session/exim-test-session.sh $(DESTDIR)/$(LBINDIR)/exim-test-session

	# Install admin scripts
	install -m 755 exim-hup/exim-hup.sh $(DESTDIR)/$(SBINDIR)/exim-hup
	install -m 755 exim-tidyall/exim-tidyall.sh $(DESTDIR)/$(SBINDIR)/exim-tidyall
	install -m 755 exim-minify-conf/exim-minify-conf.sh $(DESTDIR)/$(SBINDIR)/exim-minify-conf

	# Install user man pages
	gzip -c exim-run-acl-tests/docs/exim-run-acl-tests.1 > $(DESTDIR)/$(MANDIR)/man1/exim-run-acl-tests.1.gz
	gzip -c exim-test-session/docs/exim-test-session.1 > $(DESTDIR)/$(MANDIR)/man1/exim-test-session.1.gz

	# Install admin man pages
	gzip -c exim-hup/docs/exim-hup.8 > $(DESTDIR)/$(MANDIR)/man8/exim-hup.8.gz
	gzip -c exim-tidyall/docs/exim-tidyall.8 > $(DESTDIR)/$(MANDIR)/man8/exim-tidyall.8.gz
	gzip -c exim-minify-conf/docs/exim-minify-conf.8 > $(DESTDIR)/$(MANDIR)/man8/exim-minify-conf.8.gz

uninstall:
	# Remove user scripts
	-rm -f $(DESTDIR)/$(LBINDIR)/exim-run-acl-tests
	-rm -f $(DESTDIR)/$(LBINDIR)/exim-test-session

	# Remove admin scripts
	-rm -f $(DESTDIR)/$(SBINDIR)/exim-hup
	-rm -f $(DESTDIR)/$(SBINDIR)/exim-tidyall
	-rm -f $(DESTDIR)/$(SBINDIR)/exim-minify-conf

	# Remove user man pages
	-rm -f $(DESTDIR)/$(MANDIR)/man1/exim-run-acl-tests.1.gz
	-rm -f $(DESTDIR)/$(MANDIR)/man1/exim-test-session.1.gz

	# Remove admin man pages
	-rm -f $(DESTDIR)/$(MANDIR)/man8/exim-hup.8.gz
	-rm -f $(DESTDIR)/$(MANDIR)/man8/exim-tidyall.8.gz
	-rm -f $(DESTDIR)/$(MANDIR)/man8/exim-minify-conf.8.gz

help2man:
	help2man -n "test a series of Exim ACL checks" -s 1 -N -i exim-run-acl-tests/docs/exim-run-acl-tests.1.inc -o exim-run-acl-tests/docs/exim-run-acl-tests.1 "bash exim-run-acl-tests/exim-run-acl-tests.sh"
	help2man -n "simulates an Exim SMTP session from a remote host" -s 1 -N -o exim-test-session/docs/exim-test-session.1 "bash exim-test-session/exim-test-session.sh"

	help2man -n "signal the running Exim daemon" -s 8 -N -o exim-hup/docs/exim-hup.8 "bash exim-hup/exim-hup.sh"
	help2man -n "execute exim_tidydb for all Exim hints databases" -s 8 -N -o exim-tidyall/docs/exim-tidyall.8 "bash exim-tidyall/exim-tidyall.sh"
	help2man -n "minify an Exim configuration file" -s 8 -N -o exim-minify-conf/docs/exim-minify-conf.8 "bash exim-minify-conf/exim-minify-conf.sh"
