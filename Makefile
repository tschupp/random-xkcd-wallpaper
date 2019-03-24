OS := $(shell uname)

ifeq ($(OS), Darwin)
DIR_INSTALL := $(HOME)/Library/LaunchAgents/net.mutualtape.xkcdwallpaper.plist
else
DIR_INSTALL := $(HOME)/.xkcdwallpaper
endif

CONVERT = $(shell which convert)
LOG = $(DIR_INSTALL)/log.txt

debug: DEBUG := <string>--debug</string>

all: clean install

build: 
	mkdir -p $(DIR_INSTALL)
ifeq ($(OS), Darwin)	 
	sed $(foreach replace, \
		DIR_INSTALL CONVERT DEBUG LOG, \
		-e "s|\$${$(replace)}|$($(replace))|g") \
	plist.template > $(DIR_INSTALL)/Info.plist
endif	

dependencies:
ifeq (, $(CONVERT))
ifeq ($(OS), Darwin)
	brew install imagemagick
endif
CONVERT := $(shell which convert)
endif

install: dependencies build
	cp xkcd_wallpaper.sh $(DIR_INSTALL)
ifeq ($(OS), Darwin)
	launchctl load $(DIR_INSTALL)
endif

clean: 
	launchctl unload $(DIR_INSTALL)
	rm -rf $(DIR_INSTALL)

