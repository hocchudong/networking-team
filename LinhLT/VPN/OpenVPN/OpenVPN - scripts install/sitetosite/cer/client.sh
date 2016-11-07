#!/bin/bash
echo "OPENVPN site to site using cer by L2T"
source config.cfg
#########Tao cac file va thu muc can thiet#########
if [ -f "$dir_log" ]
	then
		echo "$dir_log da duoc tao"
	else
		mkdir -p $dir_log 
fi

if [ -f "$dir_key/keys" ]
	then
		echo "$dir_key da duoc tao"
	else
		mkdir -p $dir_key/keys
fi

if [ -f "$dir_openvpn/server.conf" ]
	then
		#rm -r $dir_openvpn/server.conf
		cat /dev/null > $dir_openvpn/server.conf
	else
		touch $dir_openvpn/server.conf
fi
#cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
#gzip -d /etc/openvpn/server.conf.gz
#########CONFIG######
cat <<EOF>> $dir_openvpn/server.conf
local $ip_public_local
remote $ip_public_remote
port $port
proto udp
dev tun
ifconfig $ip_tunnel_local $ip_tunnel_remote
persist-tun
persist-local-ip
persist-remote-ip
comp-lzo
ping 15
tls-client
ca $dir_key/keys/ca.crt
cert $dir_key/keys/client.crt
key $dir_key/keys/client.key  # This file should be kept secret
dh $dir_key/keys/dh2048.pem
tls-auth $dir_key/keys/ta.key 1 # This file is secret
route $net_lan_remote $mask_lan_remote
user nobody
group nogroup
log-append $dir_log/vpn.log
verb 1
EOF
###################