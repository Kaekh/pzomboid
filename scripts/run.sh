#!/bin/bash

set -e

DIR="/opt/pzserver"
server_ini=${DIR}/Zomboid/Server/${SERVER_NAME}.ini

updateConfigValue(){
    sed -i "s/\(^$1 *= *\).*/\1${2//&/\\&}/" "$server_ini"
}

setupServerFile(){
	if [[ ! -f "$server_ini" ]]; then
		echo "Creating file $server_ini ..."
		touch "$server_ini"

		echo "DefaultPort=${SERVER_PORT}" >> "$server_ini"
		echo "UDPPort=${SERVER_UDP_PORT}" >> "$server_ini"
		echo "Password=${SERVER_PASSWORD}" >> "$server_ini"
		echo "Public=${SERVER_PUBLIC}" >> "$server_ini"
		echo "PublicName=${SERVER_PUBLIC_NAME}" >> "$server_ini"
		echo "PublicDescription=${SERVER_PUBLIC_DESC}" >> "$server_ini"
		echo "RCONPort=${RCON_PORT}" >> "$server_ini"
		echo "RCONPassword=${RCON_PASSWORD}" >> "$server_ini"
		echo "MaxPlayers=${SERVER_MAX_PLAYER}" >> "$server_ini"
		echo "Mods=${MOD_NAMES}" >> "$server_ini"
		echo "WorkshopItems=${MOD_WORKSHOP_IDS}" >> "$server_ini"
	else
		updateConfigValue "DefaultPort" ${SERVER_PORT}
		updateConfigValue "UDPPort" ${SERVER_UDP_PORT}
		updateConfigValue "Password" ${SERVER_PASSWORD}
		updateConfigValue "Public" ${SERVER_PUBLIC}
		updateConfigValue "PublicName" "${SERVER_PUBLIC_NAME}"
		updateConfigValue "PublicDescription" "${SERVER_PUBLIC_DESC}"
		updateConfigValue "RCONPort" ${RCON_PORT}
		updateConfigValue "RCONPassword" ${RCON_PASSWORD}
		updateConfigValue "MaxPlayers" ${SERVER_MAX_PLAYER}
		updateConfigValue "Mods" "${MOD_NAMES}"
		updateConfigValue "WorkshopItems" "${MOD_WORKSHOP_IDS}"
	fi
}

startGame(){
	echo "Running game..."
	${DIR}/server/start-server.sh -servername "${SERVER_NAME}" -adminpassword "${SERVER_ADMIN_PASSWORD}"
}

echo "Checking for updates..."
steamcmd +force_install_dir "$DIR/server" +login anonymous +app_update 380870 +quit

$DIR/updater.sh updateBuildInfo

#Set up server configuration
setupServerFile

#Start server
startGame

exit 0
