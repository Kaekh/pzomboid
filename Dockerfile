FROM kaekh/steamcmd

ENV SERVER_NAME=PZserver \
    SERVER_ADMIN_PASSWORD= \
    SERVER_PUBLIC_NAME="Project Zomboid Docker Server" \ 
    SERVER_PASSWORD= \
    SERVER_PORT=16261 \
    SERVER_UDP_PORT=16262 \
    SERVER_PUBLIC=true \
    SERVER_PUBLIC_DESC= \
    SERVER_MAX_PLAYER=16 \
    RCON_PORT=27015 \
    RCON_PASSWORD= \
    MOD_NAMES= \
    MOD_WORKSHOP_IDS= \
    PUID=1000 \
    PGID=1000 

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
        lib32gcc-s1 \
        curl \
	vim \
	rsync \
	cron \
	gosu \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*


RUN useradd --no-log-init -d /opt/pzserver -s /bin/bash steam && \
    gosu nobody true; 

COPY setup.sh /
COPY --chown=steam:steam run.sh /opt/pzserver/
COPY --chown=steam:steam rcon /opt/pzserver/
COPY --chown=steam:steam updater.sh /opt/pzserver/

# Expose ports
EXPOSE $SERVER_PORT/udp
EXPOSE $SERVER_UDP_PORT/udp

ENTRYPOINT ["/setup.sh"]
