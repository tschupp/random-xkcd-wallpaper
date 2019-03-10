What this script does
---------------------
Downloads a random xkcd comic, adjusts it with ImageMagick and sets it as your desktop background on your mac. 

How to use it
-------------
Get `xkcd_wallpaper.sh` either by cloning the github project or downloading the file. 
Install ImageMagick (`ie brew install imagemagick`)

Run it from the terminal, with a keyboard shortcut or with a custom application launcher. The file `current_xkcd_wallpaper.(png | jpg)` gets saved in `$HOME/.xkcd_wallpaper`.

Gnome remarks
-------------
Adopted from https://github.com/Basphil/random-xkcd-wallpaper, I have not tested in on gnome at all. Original notes:
* To see which file is currently set as wallpaper. Run `gconf-editor` and have a look at the value `/desktop/gnome/background/picture_filename`. This file will not exist anymore though, as it gets moved to `current_xkcd_wallpaper.(png | jpg)`
* Running the script with a keyboard shortcut set in the ubuntu Keyboard Shortcuts menu does not work for the moment. It does work with compiz keyboard shortcuts though. 

