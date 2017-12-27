TOPDIR=$(shell pwd)

include $(TOPDIR)/common.mk

ALL_TARGETS =
INSTALL_TARGETS =
CLEAN_TARGETS =
DISTCLEAN_TARGETS =

all: real-all

include preload/preload.mk
include shellex.mk
include urxvt/urxvt_shellex.mk
include conf.mk
include format.mk
include doc/man/man.mk

real-all: $(ALL_TARGETS)

install: $(INSTALL_TARGETS)

clean: $(CLEAN_TARGETS)

distclean: clean $(DISTCLEAN_TARGETS)
