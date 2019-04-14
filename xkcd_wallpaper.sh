#!/bin/bash

#    random xkcd wallpaper: Downloads a random xkcd comic, adjusts it with ImageMagick and sets it as your desktop background.
#    Copyright (C) 2019 thomas@mutualtape.net

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
convert=convert
python=python
silent=FALSE
debug=FALSE

out() { echo "[$(date)] >>" $@; }
log() { if (! $silent); then out $@; fi; }
debug() { if (! $silent && $debug); then out $@; fi; }
error() { echo "[$(date)] ERROR:" $@ >&2; exit 1; }

while [ "$1" != "" ]; do
    case $1 in
        --dir )                 shift
                                directory=$1
                                ;;
        --convert )             shift
                                convert=$1
                                ;;
        --python )              shift
                                python=$1
                                ;;                        
        -s | --silent )         silent=TRUE
                                ;;
        -d | --debug )          debug=TRUE
                                ;;
        * )                     error "wrong arguments"
    esac
    shift
done

if [ ! -d "$directory" ]; then error "no working directory"; fi
cd $directory

# /random/comic redirects to random comic.
# Searches the line in the html that points to the url where the actual comic is placed.
# The image urls are of the form: http://imgs.xkcd.com/comics/.'name of comic'.(png | jpg).
comic_html=`curl -sL http://dynamic.xkcd.com/random/comic`

getImageUrl() { 
    echo $comic_html | grep -om1 'imgs.xkcd.com/comics/[^.]*\.[a-z]*' | tail -1 | awk '{print $NF}'
}
getUrl() { 
    echo $comic_html | grep -om1 'https://xkcd.com/[0-9]*'  | tail -1 | awk '{print $1}'
}
getX() { echo $1 | awk -Fx '{print $1}'; }
getY() { echo $1 | awk -Fx '{print $2}'; }

# Operating System dependent functions
source $(pwd)/xkcd_wallpaper-OS.sh

screenLockFile="$(pwd)/.screenIsLocked" 
proceed=FALSE
if [ ! -f $screenLockFile ]; then
    debug "first run"    
    proceed=TRUE
else
    if [[ `isScreenLocked` ]]; then
        debug "screen locked"
        [ ! -s $screenLockFile ] && proceed=TRUE
    else
        if [   -s $screenLockFile ]; then
            debug "logged in again at" `date` "last lock at" `cat $screenLockFile`
            echo -n "" > $screenLockFile
        else
            debug "screen not locked"    
        fi
    fi
fi    

$proceed && { 
    debug "write screenlock file"    
    date > $screenLockFile
 } || exit 0;

url="http://$(getImageUrl)"
name_pic=$(echo $url | grep -o [^/]*$)

debug "Download: $url --> $name_pic"
curl -so "$name_pic" "$url"

imgDimension=`${convert} $name_pic -format "%wx%h" info:`
screenDimension=$(getScreenDimension)
debug "Dimensions: img=$imgDimension screen=$screenDimension"

if (( `getX $imgDimension` > `getY $imgDimension` )); then
    debug "Format: landscape"
    gravity=North
else
    debug "Format: portrait"
    gravity=East
fi

wallpaper_name="xkcd-wallpaper-$name_pic.png"
# resize 1000x1000 needs to be changed to a decent fraction of the screen dimension
# todo: https://xkcd.com/720 --> recipes.png portrait looks shitty 
${convert} $name_pic -set colorspace Gray -negate -resize 1200x1200 -gravity $gravity -background black -extent $screenDimension $wallpaper_name
debug "Wallpaper generated --> $wallpaper_name"

# lets the magic happen
setBackground

# track what happened
log $(getUrl) "-->" $name_pic

# cleanup
find $(pwd) -iname "*.png" -or -iname "*.jpg" -type f | xargs rm






