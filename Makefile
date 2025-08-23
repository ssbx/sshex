
include config.mk
SHELL = /bin/sh


.PHONY: all
all:
	@echo "Run make install"

.PHONY: install
install:

.PHONY: uninstall
uninstall:


XSH_DIR = $(HOME)/.local/share/xsh

default: test2
#install: uninstall
	#ln -s $(PWD)/xsh $(HOME)/bin/
	#install -d $(XSH_DIR)
	#install -T -m 600 $(PWD)/autocomp.bashrc $(XSH_DIR)/autocomp.bashrc
	#touch $(XSH_DIR)/autocomp.hosts
	#if [ ! -f $(XSH_DIR)/config.ini ]; then \
	#install -T -m 600 $(PWD)/config.ini $(XSH_DIR)/config.ini; fi

install: config.mk

autocomp-hosts:
	xsh --xsh-genhosts

uninstall:
	rm -f $(HOME)/bin/xsh

test:
	xsh --xsh-script=tests/cisco_show_run.tcl sw-sn-02-e1-lt12-c9200l.mgmt.sn.univ-nantes.prive

test2:
	xsh --xsh-donotclose sw-sn-02-e1-lt12-c9200l.mgmt.sn.univ-nantes.prive


dev-clean:
	rm $(HOME)/.local/share/xsh/config.ini
	rm $(HOME)/.local/share/xsh/autocomp.hosts
	rm $(HOME)/.local/share/xsh/autocomp.bashrc

clean:
	rm config.status

