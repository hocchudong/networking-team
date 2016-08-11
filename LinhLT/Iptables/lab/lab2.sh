#!/bin/bash
echo "Auto config iptables"
ippublic="172.16.69.128"
intpublic="eth0"
ipdmz="10.10.10.128"
intdmz="eth1"
iplan="10.10.20.128"
intlan="eth2"
ipwebserver="10.10.10.150"
iplanssh="10.10.20.130"
lan="10.10.20.0/24"
#####
echo "INSTALL"
#####
iptables -t nat -I PREROUTING -i $intpublic -p tcp --dport 80 -j DNAT --to-destination $ipwebserver
iptables -t nat -I POSTROUTING -o $intdmz -p tcp --dport 80 -j SNAT --to-source $ipdmz
iptables -A FORWARD -i $intpublic -o $intdmz -p tcp --dport 80 -d $ipwebserver -j ACCEPT
iptables -t nat -I POSTROUTING -s $iplanssh -p tcp -d $ipwebserver --dport 22 -j SNAT --to-source $ipdmz
iptables -A FORWARD -s $iplanssh -i $intlan -o $intdmz -d $ipwebserver -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -i $intpublic -o $intdmz -d $ipwebserver -j DROP
iptables -t nat -A POSTROUTING -s $lan -o $intpublic -j SNAT --to-source $ippublic
iptables -A INPUT -i $intpublic -j DROP
#####
echo "Done"
