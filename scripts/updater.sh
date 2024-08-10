#!/bin/bash

set -e

DIR="/opt/pzserver"
VERSION=""
RESTARTSERVER=false

#Check app version and date from Steam
function getCurrentBuildVersion {

	local appInfo
	local newVersion
	local newDate

	appInfo=$(steamcmd +login anonymous +app_info_update 1 +app_info_print 380870 +quit | tr '\n' ' ')
	newVersion=$(echo "$appInfo" | grep --color=NEVER -Po '"branches"\s*{\s*"public"\s*{\s*"buildid"\s*"\K(\d*)')
	newDate=$(echo "$appInfo" | grep --color=NEVER -Po '"branches"\s*{\s*"public"\s*{\s*"buildid"\s*"\d*"\s*"timeupdated"\s*"\K(\d*)')

	#If SteamCMD returns data
	if [[ -n "$newVersion" ]] && [[ -n "$newDate" ]]; then
		VERSION="$newVersion:$newDate"
	fi
}

function updateBuildVersion {
    echo "$VERSION" > $DIR/build.info
}

function checkUpdateBuild {

	local info
	local oldVersion
	local oldDate
	local newVersion
	local newDate

	if [[ -f "$DIR/build.info" ]]; then
		info=$(head -1 $DIR/build.info)
		oldVersion=$(echo "$info" | cut -d':' -f1)
		oldDate=$(echo "$info" | cut -d':' -f2)
	else
		oldVersion=0
		oldDate=0
	fi
	if [[ -n "$VERSION" ]]; then
		newVersion=$(echo "$VERSION" | cut -d':' -f1)
		newDate=$(echo "$VERSION" | cut -d':' -f2)

		#Check if version or date changed
		if [[ "$oldVersion" -ne "$newVersion" ]] || [[ "$oldDate" -lt "$newDate" ]]; then
			RESTARTSERVER=true
		fi
	fi
}

function checkUpdateMods {

	local response
	"$DIR/rcon" -c "$DIR/rcon.yaml" "checkModsNeedUpdate" >/dev/null 2>&1
	sleep 10
	response=$(awk '/CheckModsNeedUpdate/ {lastMatch=$0} END {if (lastMatch) print lastMatch}' "$DIR/Zomboid/server-console.txt")

	if [[ "$response" =~ CheckModsNeedUpdate:.*need.*update ]]; then
		RESTARTSERVER=true
	fi
}

function restartServer {

	local numPlayers

	#check if there are players connected
	numPlayers=$("$DIR/rcon"  -c "$DIR/rcon.yaml" "players" | head -1 | awk -F'[()]' '{print $2}')

	if ! [[ "$numPlayers" =~ ^0$ ]]; then

		"$DIR/rcon"  -c "$DIR/rcon.yaml" "servermsg \"Server need to be updated!!\"" >/dev/null 2>&1
		"$DIR/rcon"  -c "$DIR/rcon.yaml" "servermsg \"Server will be restarting in 5 mins, find a safe place and log out please\"" >/dev/null 2>&1
		sleep 180
		"$DIR/rcon"  -c "$DIR/rcon.yaml" "servermsg \"Server will be restarting in 2 mins, find a safe place and log out please\"" >/dev/null 2>&1
		sleep 60
		"$DIR/rcon"  -c "$DIR/rcon.yaml" "servermsg \"Server will be restarting in 1 min, find a safe place and log out please\"" >/dev/null 2>&1
		sleep 30
		"$DIR/rcon"  -c "$DIR/rcon.yaml" "servermsg \"Server will be restarting in 30 seconds, find a safe place and log out please\"" >/dev/null 2>&1
		sleep 25
		"$DIR/rcon"  -c "$DIR/rcon.yaml" "servermsg \"Server will be restarting in 5 seconds, find a safe place and log out please\"" >/dev/null 2>&1
		sleep 5
		"$DIR/rcon"  -c "$DIR/rcon.yaml" "servermsg \"Server is restarting NOW!!!\"" >/dev/null 2>&1

	fi

	"$DIR/rcon"  -c "$DIR/rcon.yaml" "quit" >/dev/null 2>&1
}

case $1 in
    updateBuildInfo)
        getCurrentBuildVersion
        updateBuildVersion
        ;;
    *)
        getCurrentBuildVersion
        checkUpdateBuild
        checkUpdateMods
        ;;
esac

if [[ $RESTARTSERVER = true ]]; then
    restartServer
fi

exit 0
