#!/bin/bash
######install openvpn######
install_OpenVPN(){
    echo "--------------------INSTALL OPENVPN-----------------------"
    apt-get update
    apt-get install openvpn easy-rsa -y
}
##########check openvpn installed?########
check_OpenVPN(){
    INSTALLED=$(dpkg -l \grep openvpn)
    if [ "$INSTALLED" != "" ]; then
        echo "OPENVPN da duoc cai dat"
    else
        install_OpenVPN
        while [ $? !=0 ]
        do
            install_OpenVPN
        done
    fi
}
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
    echo "-----------------------Tao file server.conf----------------------"
    if [ -f "$dir_openvpn/server.conf" ]
        then
            cat /dev/null > $dir_openvpn/server.conf
        else
            touch $dir_openvpn/server.conf
    fi
}
########Cau hinh file server.conf###########
config(){
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
    secret $dir_key 0
    route $net_lan_remote $mask_lan_remote
    user nobody
    group nogroup
    log-append $dir_log/vpn.log
    verb 1
EOF
}

main(){
    echo "OPENVPN site to site using static key by L2T"
    source config.cfg
    check_OpenVPN
    prepare
    config
    service openvpn restart
}
main
