#!/bin/bash

getScreenDimension() {
    system_profiler SPDisplaysDataType | grep -m1 Resolution | sed -e 's/[^0-9]*\([0-9]*\) *x *\([0-9]*\).*/\1x\2/'
}
isScreenLocked() {
    ${python} -c 'import sys,Quartz; d=Quartz.CGSessionCopyCurrentDictionary(); print d' | grep CGSSessionScreenIsLocked | grep 1
}
setBackground() {
    # filename needs to be different from the last time the desktop had been set. It won't be changed otherwise. 
    osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$(pwd)/$wallpaper_name\"" 
}

