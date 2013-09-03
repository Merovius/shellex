INSTALL_TARGETS += install-conf

default_confs := 10-autoexec 40-escape 40-setprompt 40-sigint 90-hist 99-clear

install-conf:
	$(INSTALL) -d -m 0755 $(DESTDIR)$(PREFIX)$(LIBDIR)/shellex/conf
	for file in $(wildcard conf/*); \
	do \
		$(INSTALL) -m 0644 $${file} $(DESTDIR)$(PREFIX)$(LIBDIR)/shellex/conf/; \
	done
	$(INSTALL) -d -m 0755 $(DESTDIR)$(SYSCONFDIR)/shellex
	for link in $(default_confs); \
	do \
		[ -e $(DESTDIR)$(SYSCONFDIR)/shellex/$${link} ] || ln -s $(PREFIX)$(LIBDIR)/shellex/conf/$${link} $(DESTDIR)$(SYSCONFDIR)/shellex; \
	done
