DISTCLEAN_TARGETS += clean-mans

A2X = a2x

A2X_MAN_CALL = $(V_A2X)$(A2X) -f manpage --asciidoc-opts="-f doc/man/asciidoc.conf" $(A2X_FLAGS) $<

MANS = \
	doc/man/shellex.1

mans: $(MANS)

%.1: %.man doc/man/asciidoc.conf
	$(A2X_MAN_CALL)

%.man: %.man.in
	$(SED) $(sed_replace_vars) $< > $@

clean-mans:
	for file in $(basename $(MANS)); \
	do \
		rm -f $${file}.1 $${file}.man; \
	done
