ALL_TARGETS += shellex
INSTALL_TARGETS += install-shellex
CLEAN_TARGETS += clean-shellex

shellex: shellex.in
	echo "[SED] $@"
	$(SED) $(sed_replace_vars) $< > $@

install-shellex: shellex
	echo "[INSTALL] $<"
	$(INSTALL) -d -m 0755 $(DESTDIR)$(PREFIX)/bin
	$(INSTALL) -m 0755 shellex $(DESTDIR)$(PREFIX)/bin/

clean-shellex:
	echo "[CLEAN] shellex"
	rm -f shellex
