OS := $(shell uname)

ifeq ($(OS), Darwin)
DIR_INSTALL := $(HOME)/Library/LaunchAgents/net.mutualtape.xkcdwallpaper.plist
else
DIR_INSTALL := $(HOME)/.xkcdwallpaper
endif

CONVERT = $(shell which convert)
PYTHON = $(shell which python)
LOG = $(DIR_INSTALL)/log.txt

debug: DEBUG := <string>--debug</string>
debug: all

all: clean install

build: 
	mkdir -p $(DIR_INSTALL)
ifeq ($(OS), Darwin)	 
	sed $(foreach replace, \
		DIR_INSTALL CONVERT PYTHON LOG DEBUG, \
		-e "s|\$${$(replace)}|$($(replace))|g") \
	plist.template > $(DIR_INSTALL)/Info.plist
endif	

dependencies:
ifeq ($(OS), Darwin)
ifeq (, $(CONVERT))
	brew install imagemagick
endif
CONVERT := $(shell which convert)
ifeq (, $(PYTHON))
	brew install python
endif
PYTHON := $(shell which python)
endif

install: dependencies build
	cp xkcd_wallpaper.sh $(DIR_INSTALL)
ifeq ($(OS), Darwin)
	launchctl load $(DIR_INSTALL)
endif

clean: 
	launchctl unload $(DIR_INSTALL)
	rm -rf $(DIR_INSTALL)

