Gnome version 47

to create a dump of current extensions with configurations use
dconf dump /org/gnome/shell/extensions/ > file.txt

to restore the extensions use
dconf load /org/gnome/shell/extensions/ < file.txt
