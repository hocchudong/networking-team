#!/bin/bash
echo "OPENVPN site to site using static key by L2T"
source config.cfg
###########Cho phep chuyen tiep goi tin##########
sed -i -e 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sysctl -p
######INSTALL OpenVPN######
install_OpenVPN(){
	apt-get update
	apt-get install openvpn easy-rsa -y
}
dpkg -l "openvpn" &>/dev/null && echo "OPENVPN da duoc cai dat" || install_OpenVPN
#########Tao cac file va thu muc can thiet#########
if [ -f "$dir_log" ]
	then
		echo "$dir_log da duoc tao"
	else
		mkdir -p $dir_log 
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
secret $dir_key 0
route $net_lan_remote $mask_lan_remote
user nobody
group nogroup
log-append $dir_log/vpn.log
verb 1
EOF
##########RESTART####
service openvpn restart
#########END##########
