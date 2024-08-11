#!/bin/bash

set -e

CURRENTUID=$(id -u)
MSGERROR="\033[0;31mERROR:\033[0m"
MSGWARNING="\033[0;33mWARNING:\033[0m"
NUMCHECK='^[0-9]+$'
USER="steam"
RCONLOG="/opt/pzserver/rcon.log"

# check if the user and group IDs have been set
if [[ "$CURRENTUID" -ne "0" ]]; then
    printf "$MSGERROR Current user (%s) is not root (0)\\n" "$CURRENTUID"
    exit 1
fi

if ! [[ "$PGID" =~ $NUMCHECK ]] ; then
    printf "$MSGWARNING Invalid group id given: %s\\n" "$PGID"
    PGID="1000"
elif [[ "$PGID" -eq 0 ]]; then
    printf "$MSGERROR PGID/group cannot be 0 (root)\\nPass your group to the container using the PGID environment variable\\n"
    exit 1
fi

if ! [[ "$PUID" =~ $NUMCHECK ]] ; then
    printf "$MSGWARNING Invalid user id given: %s\\n" "$PUID"
    PUID="1000"
elif [[ "$PUID" -eq 0 ]]; then
    printf "$MSGERROR PUID/user cannot be 0 (root)\\nPass your user to the container using the PUID environment variable\\n"
    exit 1
fi

if [[ $(getent group $PGID | cut -d: -f1) ]]; then
    usermod -a -G "$PGID" steam
else
    groupmod -g "$PGID" steam
fi

if [[ $(getent passwd $PUID | cut -d: -f1) ]]; then
    USER=$(getent passwd $PUID | cut -d: -f1)
else
    usermod -u "$PUID" steam
fi

mkdir -p /opt/pzserver/Zomboid/Server || exit 1

#Check RCON port is defined
if [[ -z $RCON_PORT ]]; then
    RCON_PORT=27015
fi

#Check RCON password is defined
if [[ -z $RCON_PASSWORD ]]; then
    RCON_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 8)
fi

#RCON CLI
{
    printf "default:\n"
    printf "  address: \"127.0.0.1:%s\"\n" "$RCON_PORT"
    printf "  password: \"%s\"\n" "$RCON_PASSWORD"
    printf "  log: \"%s\"\n" "$RCONLOG"
    printf "  type: \"rcon\"\n"
    printf "  timeout: \"10s\"\n"
} > /opt/pzserver/rcon.yaml

#start up cron
service cron status &> /dev/null || service cron start

chown -R "$PUID":"$PGID" /opt/pzserver
exec gosu "$USER" "/opt/pzserver/run.sh" "$@"
