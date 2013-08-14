#
# Copyright (c) 2013, Alexey Degtyarev <alexey@renatasystems.org>. 
# All rights reserved.
#
# $Id$

NAME=GOST34.11-2012
VERSION=`cat VERSION`

DISTNAME=$(NAME)-$(VERSION)

WARNING?=-pedantic -Wall -Wstrict-prototypes -Wmissing-prototypes -Wshadow \
      -Wconversion -Wno-long-long -Wextra -Wpointer-arith -Wcast-qual \
      -Winline

OPTIMIZE?=-O3

DEBUG_FLAGS?=-g #-pg

# Configurable options ends here.

HEADERS=gost3411-2012-core.h \
	gost3411-2012-const.h gost3411-2012-precalc.h \
	gost3411-2012-mmx.h gost3411-2012-sse2.h gost3411-2012-sse41.h \
	gost3411-2012-ref.h
SOURCES=gost3411-2012.c gost3411-2012-core.c
CONFIGS=gost3411-2012-config.h

DEFAULT_INCLUDES=-I.

CC?=cc
CFLAGS=$(DEFS) ${DEBUG_FLAGS} $(OPTIMIZE) $(WARNING) $(DEFAULT_INCLUDES)

all: gost3411-2012

man: gost3411-2012.1

$(CONFIGS):
	@env CC="$(CC)" CFLAGS="$(CFLAGS)" SOURCES="${SOURCES}" \
		DEFAULT_INCLUDES="$(DEFAULT_INCLUDES)" sh configure

config: $(CONFIGS)

gost3411-2012: $(CONFIGS) $(SOURCES) $(HEADERS)
	@$(MAKE) -f auto/Makefile compile

gost3411-2012.1: gost3411-2012
	help2man --output=$@ -v "-v" -h "-h" --no-info --source="GOST R 34.11-2012" \
        --name='Portable implementation of GOST R 34.11-2012 hash function' \
	--opt-include=$@.h2m \
        ./gost3411-2012

remake: clean all

reconfig: rmconfig config

rmconfig:
	rm -f $(CONFIGS)

clean: rmconfig
	rm -f gost3411-2012 *.core core auto/Makefile api.h gost3411-2012.1

dist: clean man
	mkdir -p $(DISTNAME)
	cp $(SOURCES) $(HEADERS) $(DISTNAME) 
	cp Changelog LICENSE Makefile VERSION README configure $(DISTNAME)
	cp gost3411-2012.1 $(DISTNAME)
	cp -R auto examples $(DISTNAME)/
	find $(DISTNAME)/ -type d -name .svn -exec rm -r {} \;
	-rm $(DISTNAME).tar.gz 2>/dev/null
	tar czf $(DISTNAME).tar.gz $(DISTNAME)
	rm -r $(DISTNAME)

distclean: 
	-rm $(DISTNAME).tar.gz 2>/dev/null

test: gost3411-2012
	./gost3411-2012 -t

bench: 
	$(MAKE) remake CC=clang && ./gost3411-2012 -b
	$(MAKE) remake CC=gcc46 && ./gost3411-2012 -b
	$(MAKE) remake CC=gcc47 && ./gost3411-2012 -b
	$(MAKE) remake CC=gcc && ./gost3411-2012 -b
	which icc && $(MAKE) remake CC=icc && ./gost3411-2012 -b || true
