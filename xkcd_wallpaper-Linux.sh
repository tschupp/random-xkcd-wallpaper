#!/bin/bash

getScreenDimension() {
    xrandr -q | grep "Screen 0" | sed -e 's/.*current \([0-9]*\) x \([0-9]*\).*/\1x\2/'
}
isScreenLocked() {
    gsettings get org.gnome.desktop.lockdown disable-lock-screen
}
setBackground() {
    gsettings set com.canonical.unity-greeter background "$(pwd)/$wallpaper_name"
}

