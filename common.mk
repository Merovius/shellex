INSTALL=install
SED=sed
ifndef PREFIX
  PREFIX=/usr
endif
ifndef SYSCONFDIR
  ifeq ($(PREFIX),/usr)
    SYSCONFDIR=/etc
  else
    SYSCONFDIR=$(PREFIX)/etc
  endif
endif
LIBDIR ?= /lib

SHELLEX_CFLAGS  = -std=c99
SHELLEX_CFLAGS += -Wall
SHELLEX_CFLAGS += -Wunused-value

sed_replace_vars := -e 's,@DESTDIR@,$(DESTDIR),g' \
                    -e 's,@PREFIX@,$(PREFIX),g' \
                    -e 's,@LIBDIR@,$(LIBDIR),g' \
                    -e 's,@SYSCONFDIR@,$(SYSCONFDIR),g'

V ?= 0
ifeq ($(V),0)
# Don't print command lines which are run
.SILENT:

endif

# always remake the following targets
.PHONY: install clean dist distclean
