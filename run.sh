#!/usr/bin/env bash
# shellcheck disable=2091

echo "please wait..."
for dep in readlink mkdir touch java tput pwd cat dirname rm
do command -v "$dep" > /dev/null || { echo "command $dep not found. please make sure it is in the path.";exit 1;}
done

[[ "$COLUMNS" == '' ]] && COLUMNS="$(tput cols )"
[[ "$LINES"   == '' ]] &&   LINES="$(tput lines)"
# shellcheck disable=2034
ROWS="$COLUMNS"

[[ ! -d servers ]] && mkdir servers
[[ ! -f serverlist ]] && touch serverlist


CMD="$0"
while :; do
    if [[ -L "$CMD" ]]
    then CMD="$(readlink "$CMD")"
    elif [[ -f "$CMD" ]]
    then break
    else echo "error!";exit 1
    fi
done
cd "$(dirname "$CMD")" || exit 1
DirData="$(pwd)"
# shellcheck disable=2034
DirServers="$DirData/servers"
cd servers || { mkdir servers && cd servers || exit 1 ;}
for server in *
do ListServers+=("$server")
done
cd .. || exit 255

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
echo "done"

tput smcup
# downloader software
    if command -v axel > /dev/null
    then
    function dl {
        :
    }
    else 
        echo "no supported downloader found. make sure one of these in in the PATH:"
        echo "axel | fast downloads "
        echo "curl | nice progress bar"
        echo "wget | eazy to use"
        echo "I recommend axel, as it is superfast with it's 4 connections."
    fi
#

# lists
    function ListGenServer {
        for server in "${ListServers[@]}"
        do echo "$server \` off "
        done # $(grep name "servers/$server/info.txt" | cut -d '=' -f 2 || echo .)
    }
    function ListGenServerOpts {
        echo "start \` off"
        echo "world \` off"
        [[ -d "servers/$SelServer/mc/plugins" ]] && echo "plugins \` off"
        [[ -d "servers/$SelServer/mc/plugins" ]] && echo "mods \` off"
    }
# menus
    function menu.main {
        i="$(dialog --stdout \
            --title "mcsm main menu" \
            --radiolist "what can I do for you today?" 0 0 0\
            "list servers" '' on \
            exit '' off)"
        case "$i" in
            "list servers" ) next=menu.servers;;
            exit ) next="break";;
        esac
    }
    function menu.msg {
        dialog --msgbox "$@" 0 0
    }
    # shellcheck disable=2046
    function menu.servers {
        i="$(dialog --stdout \
        --title "server list"\
        --radiolist "select a server:" 0 0 0\
        back '' on \
        more '' off \
        $(ListGenServer) \
        )"
        case "$i" in
            back ) next=menu.main;;
            more ) next=menu.servers.more;;
            * ) next=menu.server; SelServer="$i";;
        esac
    }
    function menu.servers.more {
        i="$(dialog --stdout \
            --title "servers: more" \
            --radiolist "choose an option:" 0 0 0 \
            "b" "back" on \
            "n" "new server" off \
            "r" "remove a server" off \
        )"
        case "$i" in
            b ) next=menu.servers;;
            n ) next=menu.server.make;;
            r ) next="menu.msg action not supported";;
        esac
    }
    # shellcheck disable=2046
    function menu.server {
        . "servers/$SelServer/info.sh"
        i="$(dialog --stdout\
        --title "options for server"\
        --radiolist "$SelServer" 0 0 0\
        back '' on\
        $(ListGenServerOpts)\
        )"
        case "$i" in
            back ) next=menu.servers;server='';;
            start ) next=log.server.start;;
            world ) next=menu.server.world;;
        esac
    }
#
    function log.server.start {
        java -Xmx "$opt_ram_max" -Xms "$opt_ram_min" -jar "$jarfile" nogui
    }
#

next="menu.main"
while :
do
    $next || next=menu.main
    clear
done
tput rmcup

