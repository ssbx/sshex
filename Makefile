
include config.mk
SHELL = /bin/sh


.PHONY: all
all:
	@echo "Run make install"

.PHONY: install
install:

.PHONY: uninstall
uninstall:


SSHE_DIR = $(HOME)/.local/share/sshe

default: test2
#install: uninstall
	#ln -s $(PWD)/sshe $(HOME)/bin/
	#install -d $(SSHE_DIR)
	#install -T -m 600 $(PWD)/autocomp.bashrc $(SSHE_DIR)/autocomp.bashrc
	#touch $(SSHE_DIR)/autocomp.hosts
	#if [ ! -f $(SSHE_DIR)/config.ini ]; then \
	#install -T -m 600 $(PWD)/config.ini $(SSHE_DIR)/config.ini; fi

install: config.mk

autocomp-hosts: 
	sshe --sshe-genhosts

uninstall:
	rm -f $(HOME)/bin/sshe

test:
	sshe --sshe-script=tests/cisco_show_run.tcl sw-sn-02-e1-lt12-c9200l.mgmt.sn.univ-nantes.prive

test2:
	sshe --sshe-donotclose sw-sn-02-e1-lt12-c9200l.mgmt.sn.univ-nantes.prive


dev-clean:
	rm $(HOME)/.local/share/sshe/config.ini
	rm $(HOME)/.local/share/sshe/autocomp.hosts
	rm $(HOME)/.local/share/sshe/autocomp.bashrc

clean:
	rm config.status

