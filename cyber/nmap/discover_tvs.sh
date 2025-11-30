#!/bin/bash
export PS4='\033[0;33m$0:$LINENO [$?]+ \033[0m '

# What network and port to scan
RHOST=${1:-192.168.0.0}
RMASK=${2:-24}

# -- Scripts --
SCRIPTS="broadcast-upnp-info"        # UPnP / DLNA Universal Plug n' Play
add_script () {
	local SCRIPT=$1
	ls /usr/share/nmap/scripts | grep --quiet ${SCRIPT} && SCRIPTS+=",${SCRIPT}" || echo "[WARN]: nmap script \"${SCRIPT}\" not found!"
}
add_script "broadcast-dhcp-discover" # DHCP fingerprinting (many TVs expose vendor strings)
add_script "mdns-discover"           # mDNS / Chromecast, AirPlay
add_script "ssdp-discover"           # SSDP (Roku, Fire TVs, Sony TVs)
add_script "upnp-info"               # UPnP / DLNA Universal Plug n' Play
add_script "x11-access"              # x11 remote desktop server

# -- Scripts --
PORTS="80"     # HTTP
PORTS+=",1900" # SSDP/UPnP (Roku, LG, Fire TV, Samsung)
PORTS+=",3000" # LG smart TV http service
PORTS+=",3001" # LG smart TV http service
PORTS+=",3702" # WS-Discovery (Sony / Samsung)
PORTS+=",5353" # mDNS / Chromecast
PORTS+=",7000" # AirTunes rtspd
PORTS+=",8008" # Chromecast HTTP/HTTPS API
PORTS+=",8009" # Chromecast HTTP/HTTPS API
PORTS+=",8060" # Roku ECP
PORTS+=",8443" # Smart TV HTTPS APIs
PORTS+=",8612" # Roku SSDP alt
PORTS+=",9080" # glrpc

# -- RUN COMMAND --
set -x
nmap -sS -sU -T4 --top-ports 50 \
  --open \
  --script "${SCRIPTS}"\
  -p ${PORTS} \
  "${RHOST}/${RMASK}" && echo "[DONE]" || echo "[FAILED]"
set +x

