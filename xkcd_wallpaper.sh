#!/bin/bash

#    random xkcd wallpaper: Downloads a random xkcd comic, adjusts it with ImageMagick and sets it as your desktop background.
#    Copyright (C) 2011  Basil Philipp, basil.philipp@gmail.com

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>

# Creates working directory. Picture will be saved in this directory.
directory="$HOME/.xkcd_wallpaper"
if [ ! -d "$directory" ]; then mkdir $directory; fi
cd $directory

# oldschool helper
log() {
    echo ">> $1" >&2
}

# /random/comic redirects to random comic.
# Searches the line in the html that points to the url where the actual comic is placed.            # there are sometimes
# The image urls are of the form: http://imgs.xkcd.com/comics/.'name of comic'.(png | jpg).         # several images,
getImageUrl() {                                                                                     # lets get the last one:
    curl -sL http://dynamic.xkcd.com/random/comic/ | grep -om1 'imgs.xkcd.com/comics/[^.]*\.[a-z]*' | tail -1 | awk '{print $NF}'
}

getScreenDimension() {
    system_profiler SPDisplaysDataType | grep -m1 Resolution | sed -e 's/[^0-9]*\([0-9]*\) *x *\([0-9]*\).*/\1x\2/'
}
getX() {
    echo $1 | awk -Fx '{print $1}'
}
getY() {
    echo $1 | awk -Fx '{print $2}'
}


url="http://$(getImageUrl)"
name_pic=$(echo $url | grep -o [^/]*$)

log "Download: $url --> $name_pic"
curl -so "$name_pic" "$url"

imgDimension=`convert $name_pic -format "%wx%h" info:`
screenDimension=$(getScreenDimension)
log "Dimensions: img=$imgDimension screen=$screenDimension"


if (( `getX $imgDimension` > `getY $imgDimension` )); then
    log "Format: landscape"
    gravity=North
else
    log "Format: portrait"
    gravity=East
fi

wallpaper_name="xkcd-wallpaper-$name_pic.png";
convert $name_pic -set colorspace Gray -negate -resize 1000x1000 -gravity $gravity -background black -extent $screenDimension $wallpaper_name
echo "Wallpaper generated --> $wallpaper_name"

setDesktopGnome() {
    gconftool-2 --set --type=string /desktop/gnome/background/picture_filename $(pwd)/xkcd-wallpaper.png
    #For some reason, if the image is moved to fast (e.g without a wait) the background does not get set.
    sleep 1
}
 
setDesktopMacOs() {
    # filename needs to be different from the last time the desktop had been set. Otherwise it will not change. Therefore $wallpaper 
    osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$(pwd)/$wallpaper_name\"" 
}

setDesktopMacOs






