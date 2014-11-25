VERSION := 6.9.0-0
TARBALL := ImageMagick.tar.bz2
EXTRACT_DIR := ImageMagick-$(VERSION)
EXTRACTED := $(EXTRACT_DIR)/.extracted
BUILT_DEP := .built-dep
BUILT := $(EXTRACT_DIR)/.built

PREFIX := /usr

all: build

.PHONY: all

$(TARBALL):
	curl -SsLo "$@" \
	  http://mirror.checkdomain.de/imagemagick/ImageMagick-$(VERSION).tar.bz2

$(EXTRACTED): $(TARBALL)
	tar xjf "$(TARBALL)" --no-same-owner
	touch "$@"

$(BUILT_DEP):
	apt-get update -qq
	apt-get install -qy build-essential
	apt-get build-dep -qy imagemagick
	touch "$@"

build: $(BUILT)

.PHONY: build

$(BUILT): $(EXTRACTED) $(BUILT_DEP)
	cd "$(EXTRACT_DIR)" && \
	  ./configure "--prefix=$(PREFIX)" && \
	  make
	touch "$@"

install: build
	cd "$(EXTRACT_DIR)" && make install

.PHONY: install

clean:
	rm "$(BUILT_DEP)"
	rm "$(TARBALL)"
	rm -rf "$(EXTRACT_DIR)"

.PHONY: clean
