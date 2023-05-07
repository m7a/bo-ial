MDVL_CI_PHOENIX_ROOT = /data/main/120_mdvl_rr
IAL_SRC              = $(MDVL_CI_PHOENIX_ROOT)/bo-ial
ARCHIVEBOX           = ../data

all: archivebox/script.js index.xhtml

archivebox/script.js: $(ARCHIVEBOX)/index.sqlite3 $(IAL_SRC)/pages_archivebox.sql
	$(IAL_SRC)/pages_archivebox.sql $(ARCHIVEBOX)/index.sqlite3

index.xhtml: tpl.xhtml $(IAL_SRC)/remove_containers.xsl
	xmlstarlet tr --xinclude $(IAL_SRC)/remove_containers.xsl tpl.xhtml \
								> index.xhtml

tpl.xhtml: $(IAL_SRC)/index.xhtml
	cp $< $@
