# Makefile - Dot Files Manager
# Copyright (c) 2015 Arkadiusz Bokowy

PREFIX ?= /usr/local

dottie:

.PHONY: clean
clean:
	rm -f dottie

.PHONY: install
install: dottie
	install -s $< $(DESTDIR)$(PREFIX)/bin

.PHONY: uninstall
uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/dottie
