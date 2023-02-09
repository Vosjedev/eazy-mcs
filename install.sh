#!/usr/bin/env bash

command -v dialog || {
    echo "dialog not found. trying to install it..."
    if command -v apt > /dev/null
    then pkg="sudo apt -y install dialog"
    elif command -v dnf > /dev/null
    then pkg="sudo dnf install dialog"
    elif command -v pacman > /dev/null
    then pkg="sudo pacman -Sy dialog"
    else echo "no supported packager found. please install it manualy."; pkg="exit 1"
    fi
    $pkg || echo -e "=================\nerror, please install dialog manualy."
}
dialog --title ram --no-button 'oke!' --yesno "you are going to select the amount of ram for your server. you can choose any number. later you are going to specify a unit.\nselect yes if you are ready." 0 0

echo "
# settings

" > settings.sh
chmod +x settings.sh