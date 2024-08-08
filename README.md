# Project Zomboid Server

Dockerized version of [Project Zomboid](https://store.steampowered.com/app/108600/Project_Zomboid/) dedicated server.

## Setup

You'll need to bind a local directory to the Docker container's `/opt/pzserver/Zomboid` directory. This directory will hold the following directories:

-   `/Logs` - folder with history logs
-   `/Saves` - folder with server files
-   `/Server` - folder with server options
-   `/backups` - folder with backups
-   `/db` - folder with database of game
-   `/options.ini` - file with configuration to start up server
-   `/server-console.txt` - file with logs of server


```bash
docker run \
--detach \
--name=pzomboid \
--restart unless-stopped \
--volume /path/to/server:/opt/pzserver/Zomboid \
--env SERVER_NAME=ServerName \
--env SERVER_PASSWORD=serverpassword
--env SERVER_ADMIN_PASSWORD=adminpassword
--env SERVER_PUBLIC_NAME=Public name
--env RCON_PASSWORD=
--env MOD_NAMES=
--env MOD_WORKSHOP_IDS=
--env PUID=1000
--env PGID=1000
--publish 16261:16261/udp \
--publish 16262:16262/udp \
kaekh/pzomboid:latest
```

<details> 
<summary>Explanation of the command</summary>

* `--detach` -> Starts the container detached from your terminal<br> 
* `--name` -> Gives the container a unique name
* `--restart unless-stopped` -> Automatically restarts the container unless the container was manually stopped
* `--volume` -> Binds the Project Zomboid server folder to the folder you specified
Allows you to easily access your server files
* For the environment (`--env`) variables please see [here](https://github.com/Kaekh/pzomboid#environment-variables)
* `--publish` -> Specifies the ports that the container exposes<br> 
</details>

### Docker Compose

If you're using [Docker Compose](https://docs.docker.com/compose/):

```yaml
version: "3.9"
services:
    pzomboid:
    image: kaekh/pzomboid
    container_name: pzomboid
    restart: "unless-stopped"
    environment:
      - SERVER_NAME=ServerName
      - SERVER_PASSWORD=serverpassword
      - SERVER_ADMIN_PASSWORD=adminpassword
      - SERVER_PUBLIC_NAME=Public name
      - RCON_PASSWORD=
      - MOD_NAMES=
      - MOD_WORKSHOP_IDS=
      - PUID=1000
      - PGID=1000
    ports:
      - "16261:16261/udp"
      - "16262:16262/udp"
    volumes:
      - ./path/to/server:/opt/pzserver/Zomboid
```

## Environment Variables

| Parameter               | Default          | Function                                                        |
|-------------------------|:----------------:|-----------------------------------------------------------------|
| `SERVERNAME`            |   `ServerName`   | name of the server                                              |
| `SERVER_PASSWORD`       | `serverpassword` | password to login into server                                   |
| `SERVER_ADMIN_PASSWORD` | `adminpassword`  | admin password                                                  |
| `SERVER_PUBLIC_NAME`    |  `Public name`   | name will be show when servers are listed in game               |
| `RCON_PASSWORD`         |        ``        | password to connect with RCON Cli, by default will be generated |
| `MOD_NAMES`             |        ``        | list of mods names separated by ; check [Modding](https://github.com/Kaekh/pzomboid#modding)   |
| `MOD_WORKSHOP_IDS`      |        ``        | list of mods ids separated by ; check [Modding](https://github.com/Kaekh/pzomboid#modding)     |
| `PGID`                  |      `1000`      | set the group ID of the user the server will run as             |
| `PUID`                  |      `1000`      | set the user ID of the user the server will run as              |


## Modding

Mods are supported via steam. To intall them id from workshop and name is needed

-   WorkshopID can be found in %Path to your Steam folder%\Steam\steamapps\workshop\content\108600\2169435993\mods\<br>
     In this example 2169435993 is the Workshop ID
-   ModName can be found in %Path to your Steam folder%\Steam\steamapps\workshop\content\108600\2169435993\mods\ModOptions\mod.info<br>
     ModName can be found into the mod.info id=modoptions

To install this mod environment vars must be changed like this:<br>
MOD_NAMES=modoptions;<br>
MOD_WORKSHOP_IDS=2169435993;<br>

In case to install multiple mods they have to be separated by ; and have the same order in both vars


See more in [Project Zomboid wiki](https://pzwiki.net/wiki/Installing_mods)
