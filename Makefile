OS := $(shell uname)
ifeq ($(OS), Darwin)
DIR_INSTALL := $(HOME)/Library/LaunchAgents/net.mutualtape.xkcdwallpaper.plist
CMD_INSTALL := brew install
else ifeq ($(OS), Linux)
DIR_INSTALL := $(HOME)/.xkcdwallpaper
CMD_INSTALL := apt-get install
else
$(error OS $(OS) not supported)
endif

CONVERT = $(shell which convert)
PYTHON = $(shell which python)
LOG = $(DIR_INSTALL)/log.txt

debug: DEBUG := <string>--debug</string>
debug: all

all: clean install-$(OS)

install: dependencies
	mkdir -p $(DIR_INSTALL)
	cp xkcd_wallpaper.sh $(DIR_INSTALL)
	cp xkcd_wallpaper-$(OS).sh $(DIR_INSTALL)/xkcd_wallpaper-OS.sh
install-Darwin: install
	sed $(foreach replace, \
		DIR_INSTALL CONVERT PYTHON LOG DEBUG, \
		-e "s|\$${$(replace)}|$($(replace))|g") \
	plist.template > $(DIR_INSTALL)/Info.plist
	launchctl load $(DIR_INSTALL)

clean: clean-$(OS)
	rm -rf $(DIR_INSTALL)
clean-Darwin: 
	launchctl unload $(DIR_INSTALL)

dependencies: 
ifeq (, $(CONVERT))
	$(CMD_INSTALL) imagemagick
endif
CONVERT := $(shell which convert)
ifeq (, $(PYTHON))
	$(CMD_INSTALL) python
endif
PYTHON := $(shell which python)
	
