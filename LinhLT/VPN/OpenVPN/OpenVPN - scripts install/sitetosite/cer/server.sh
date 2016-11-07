#!/bin/bash
echo "OPENVPN site to site using cer by L2T"
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
if [ -f "$dir_key" ]
	then
		echo "$dir_key da duoc tao"
	else
		make-cadir /etc/openvpn/easy-rsa
fi
if [ -f "$dir_openvpn/server.conf" ]
	then
		#rm -r $dir_openvpn/server.conf
		cat /dev/null > $dir_openvpn/server.conf
	else
		touch $dir_openvpn/server.conf
fi
#######################Gen CER#############
###########################################
##########export KEY_COUNTRY="US"##########
##########export KEY_PROVINCE="CA"#########
##########export KEY_CITY="SanFrancisco"###
##########export KEY_ORG="Fort-Funston"####
##########export KEY_EMAIL="me@myhost.mydomain"
##########export KEY_OU="MyOrganizationalUnit"
##########X509 Subject Field###############
##########export KEY_NAME="EasyRSA"########
###########################################
#############Edit vars file##############
#sed -i "s/US/VN/g" $dir_key/var
#sed -i 's/export KEY_COUNTRY="US"/export KEY_COUNTRY="VN"/g' $dir_key/var
###
cd $dir_key
sed -e 's/export KEY_COUNTRY="US"/export KEY_COUNTRY="VN"/g' \
-e 's/export KEY_PROVINCE="CA"/export KEY_PROVINCE="HaNoi"/g' \
-e 's/export KEY_CITY="SanFrancisco"/export KEY_CITY="HaDong"/g' \
-e 's/export KEY_ORG="Fort-Funston"/export KEY_ORG="VNPT"/g' \
-e 's/export KEY_EMAIL="me@myhost.mydomain"/export KEY_EMAIL="admin@vnpt.vn"/g' \
-e 's/export KEY_OU="MyOrganizationalUnit"/export KEY_OU="VNPTDATA"/g' \
-e 's/export KEY_NAME="EasyRSA"/export KEY_NAME="server"/g' \
$dir_key/vars >> $dir_key/vars
#########################################
############Build key####################
#./build-key --batch username
#########################################
source $dir_key/vars
bash $dir_key/clean-all
bash $dir_key/build-ca --batch
#cat <<EOF | bash $dir_key/build-ca
#VN
#HaNoi
#HaDong
#VNPT
#VNPTDATA
#server
#server
#admin@vnpt.vn
#EOF
#
bash $dir_key/build-dh
bash $dir_key/build-key-server --batch server
#sleep 120
#cat <<EOF | bash $dir_key/build-key-server server
#VN
#HaNoi
#HaDong
#VNPT
#VNPTDATA
#server
#server
#admin@vnpt.vn
#.
#.
#y
#y
#EOF
#
openvpn --genkey --secret $dir_key/keys/ta.key
bash $dir_key/build-key --batch client
#
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
tls-server
ca $dir_key/keys/ca.crt
cert $dir_key/keys/server.crt
key $dir_key/keys/server.key  # This file should be kept secret
dh $dir_key/keys/dh2048.pem
tls-auth $dir_key/keys/ta.key 0 # This file is secret
route $net_lan_remote $mask_lan_remote
user nobody
group nogroup
log-append $dir_log/vpn.log
verb 1
EOF
###########COPY KEY sang client######
cd $dir_key/keys
scp ca.crt client.crt client.key dh2048.pem ta.key $user@$ip_public_remote:$dir_key/keys
##########RESTART####
service openvpn restart
service openvpn status
#########END##########



