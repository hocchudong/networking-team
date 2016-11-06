#!/bin/bash
#########Gen key########
source config.cfg
if [ -f "$dir_key" ]
	then
		rm -r $dir_key
fi
openvpn --genkey --secret $dir_key
scp $dir_key $user@$ip_public_remote:$dir_key
#######Restart########
service openvpn restart
service openvpn status
#######END##########