#!/bin/bash
#########Tao cac file va thu muc can thiet#########
prepare(){
    echo "-----------------Cho phep chuyen tiep goi tin------------------"
    sed -i -e 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
    sysctl -p
    echo "----------------------Check thu muc log---------------------"
    if [ -f "$dir_log" ]
        then
            echo "$dir_log da duoc tao"
        else
            mkdir -p $dir_log 
    fi
    echo "---------------------Check thu muc key----------------------"
    if [ -f "$dir_key/keys" ]
        then
            echo "$dir_key da duoc tao"
    else
    	mkdir -p $dir_key/keys
    fi
    echo "-----------------------Tao file server.conf----------------------"
    if [ -f "$dir_openvpn/server.conf" ]
        then
    	cat /dev/null > $dir_openvpn/server.conf
        else
    	touch $dir_openvpn/server.conf
    fi
}
#########CONFIG######
config (){
    echo "-----------------Cau hinh file server.conf--------------------"
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
}
main(){
    echo "OPENVPN site to site using cer by L2T"
    source config.cfg
    prepare
    config
}
main
###################