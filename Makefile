VERSION := 6.9.1-6
TARBALL := ImageMagick.tar.bz2
SIGNATURE := $(TARBALL).asc
EXTRACT_DIR := ImageMagick-$(VERSION)
EXTRACTED := $(EXTRACT_DIR)/.extracted
BUILT_DEP := .built-dep
BUILT := $(EXTRACT_DIR)/.built

PREFIX := /usr

all: verify build

.PHONY: all

$(TARBALL): $(SIGNATURE)
	curl -SsLo "$@" \
		http://www.imagemagick.org/download/ImageMagick-$(VERSION).tar.bz2

$(SIGNATURE):
	curl -SsLo "$@" \
		http://www.imagemagick.org/download/ImageMagick-$(VERSION).tar.bz2.asc

verify: $(TARBALL)
	gpg --keyserver pgp.mit.edu --recv-keys 8277377A
	gpg --verify $(SIGNATURE) $(TARBALL)


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
