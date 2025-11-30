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

# -- RUN COMMAND --
PORTS="53,67,68,80,443,1900,3702,5353,8008,8009,8060,8443"
set -x
nmap -sS -sU -T4 --top-ports 50 \
  --open \
  --script "${SCRIPTS}"\
  -p ${PORTS} \
  "${RHOST}/${RMASK}" && echo "[DONE]" || echo "[FAILED]"
set +x

