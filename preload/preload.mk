ALL_TARGETS += preload/shellex_preload.so
INSTALL_TARGETS += install-shellex_preload
CLEAN_TARGETS += clean-shellex_preload

SHELLEX_PRELOAD_LDFLAGS += -shared
SHELLEX_PRELOAD_CFLAGS += -fPIC

preload/shellex_preload.so: preload/main.c
	echo "[CC] $@"
	$(CC) $(SHELLEX_CPPFLAGS) $(CPPFLAGS) $(SHELLEX_CFLAGS) $(CFLAGS) $(SHELLEX_PRELOAD_CFLAGS) $(LDFLAGS) $(SHELLEX_LDFLAGS) $(SHELLEX_PRELOAD_LDFLAGS) -o $@ $<

install-shellex_preload: preload/shellex_preload.so
	echo "[INSTALL] $<"
	$(INSTALL) -d -m 0755 $(DESTDIR)$(PREFIX)$(LIBDIR)/shellex
	$(INSTALL) -m 0755 $< $(DESTDIR)$(PREFIX)$(LIBDIR)/shellex/

clean-shellex_preload:
	echo "[CLEAN] shellex_preload"
	rm -f preload/shellex_preload.so
