ALL_TARGETS += urxvt/shellex
INSTALL_TARGETS += install-urxvt_shellex
CLEAN_TARGETS += clean-urxvt_shellex

urxvt/shellex: urxvt/shellex.in
	echo "[SED] $@"
	$(SED) $(sed_replace_vars) $< > $@

install-urxvt_shellex: urxvt/shellex
	echo "[INSTALL] $<"
	$(INSTALL) -d -m 0755 $(DESTDIR)$(PREFIX)$(LIBDIR)/shellex/urxvt
	$(INSTALL) -m 0644 urxvt/shellex $(DESTDIR)$(PREFIX)$(LIBDIR)/shellex/urxvt/

clean-urxvt_shellex:
	echo "[CLEAN] urxvt/shellex"
	rm -f urxvt/shellex
