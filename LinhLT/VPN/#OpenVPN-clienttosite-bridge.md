#OpenVPN client to site bridge
#1. Mô hình
![](http://i.imgur.com/vt6EG32.jpg)

- Mục đích: 
	- Khi client truy cập vào vpn server thì sẽ nhận được địa chỉ ip cùng dải với mạng LAN private.
	- Khi đó, client có thể nói chuyện dễ dàng với các máy trong mạng LAN private.

#2. Thực hiện
##2.1 Các bước cần thiết.
- Cho phép chuyển tiếp gói tin. Bỏ dòng comment sau trong file `/etc/sysctl.conf`.
```sh
net.ipv4.ip_forward = 1
```
- Cài đặt các gói cần thiết:
```sh
apt-get install bridge-utils openvpn easy-rsa
```

##2.2 Chạy đoạn script tạo ra switch ảo với gói linux bridge
Các bạn cần phải thay đổi các thông số: ** br, tap, eth, eth_ip, eth_netmask, and eth_broadcast** cho phù hợp với mô hình của đề bài.

```sh
#!/bin/bash

#################################
# Set up Ethernet bridge on Linux
# Requires: bridge-utils
#################################

# Define Bridge Interface
br="br0"

# Define list of TAP interfaces to be bridged,
# for example tap="tap0 tap1 tap2".
tap="tap0"

# Define physical ethernet interface to be bridged
# with TAP interface(s) above.
eth="eth1"
eth_ip="10.10.10.134"
eth_netmask="255.255.255.0"
eth_broadcast="10.10.10.255"

for t in $tap; do
    openvpn --mktun --dev $t
done

brctl addbr $br
brctl addif $br $eth

for t in $tap; do
    brctl addif $br $t
done

for t in $tap; do
    ifconfig $t 0.0.0.0 promisc up
done

ifconfig $eth 0.0.0.0 promisc up

ifconfig $br $eth_ip netmask $eth_netmask broadcast $eth_broadcast
```

##2.3 Tạo key
```sh
make-cadir /etc/openvpn/easy-rsa
```
- Chỉnh sửa các thông số trong những dòng sau cho phù hợp với yêu cầu của bạn
```sh
vi /etc/openvpn/easy-rsa/vars
```

```sh
export KEY_COUNTRY="VN"
export KEY_PROVINCE="HN"
export KEY_CITY="HD"
export KEY_ORG="VNPT"
export KEY_EMAIL="admin@vnpt.vn"
export KEY_OU="VNPT"

# X509 Subject Field
export KEY_NAME="server"
```

- Tạo key
```sh
cd /etc/openvpn/easy-rsa/
source vars
./clean-all
./build-dh
./pkitool --initca
./pkitool --server server
cd keys
openvpn --genkey --secret ta.key
```

- Sao chép các file key đến thư mục openvpn
```sh
cp server.crt server.key ca.crt dh2048.pem ta.key /etc/openvpn/
```

##2.4 Tạo key file cho client
```sh
cd /etc/openvpn/easy-rsa/
source vars
./pkitool client-name
```

Các file **client-name.crt và client-name.key** sẽ được tạo ra. Client sẽ dùng các file này đế truy cập vào vpn server.

##2.5 Cấu hình server.conf

```sh
cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
gzip -d /etc/openvpn/server.conf.gz
```

- Sửa file server.conf với các thông số sau:

- 1. 

```sh
;dev tap
dev tun
```

**thành**

```sh
dev tap0
;dev tun
```

- 2.
```sh
dh dh1024.pem
```
**thành**
```sh
dh dh2048.pem
```

- 3.
```sh
server 10.8.0.0 255.255.255.0
```
**thành**
```sh
;server 10.8.0.0 255.255.255.0
```

- 4.
```sh
;server-bridge 10.8.0.4 255.255.255.0 10.8.0.50 10.8.0.100
```
**thành**
```sh
server-bridge 10.10.10.140 255.255.255.0 10.10.10.150 10.10.10.250
```

- 5.
```sh
;push “route 192.168.10.0 255.255.255.0”

```
**thành**
```sh
push “route 10.10.10.0 255.255.255.0”
```

- 6.
```sh
;push “redirect-gateway def1 bypass-dhcp”
```
**thành**
```sh
push “redirect-gateway def1 bypass-dhcp”
```

- 7.
```sh
;tls-auth ta.key 0 # This file is secret
```
**thành**
```sh
tls-auth ta.key 0 # This file is secret
```

- 8.
```sh
;user nobody
;group nogroup
```
**thành**
```sh
user nobody
group nogroup
```

##2.6 Cấu hình iptables
```sh
iptables -A INPUT -i tap0 -j ACCEPT
iptables -A INPUT -i br0 -j ACCEPT
iptables -A FORWARD -i br0 -j ACCEPT
```

##2.7 Tạo file client.opvn
```sh
client
dev tap
;dev tun
;dev-node MyTap
;proto tcp
proto udp
remote 10.10.40.138 1194
;remote my-server-2 1194
;remote-random
resolv-retry infinite
nobind
;user nobody
;group nobody
persist-key
persist-tun
;http-proxy-retry # retry on connection failures
;http-proxy [proxy server] [proxy port #]
;mute-replay-warnings
ca ca.crt
cert win10.crt
key win10.key
remote-cert-tls server
tls-auth ta.key 1
;cipher x
comp-lzo
verb 3
;mute 20
```

Chép các file từ server về client, để cùng thư mục với file opvn:
```sh
/etc/openvpn/ca.crt
/etc/openvpn/ta.key
/etc/openvpn/easy-rsa/keys/client-name.crt
/etc/openvpn/easy-rsa/keys/client-name.key
```

#3. Kết quả
- IP khi máy client kết nối vào mạng vpn
![](http://image.prntscr.com/image/6d96a3c05930463087f87ebd9c76f369.png)


- Thử ping máy client1 trong mạng Lanprivate
![](http://image.prntscr.com/image/2cddb08bf7cd41579d525702fc9c2cc8.png)

- Gói tin bắt được.
![](http://image.prntscr.com/image/e7e997b72db74fcd92b7fe94578bc67c.png)

#4. Lưu ý:

Khi bạn muốn dừng chạy openvpn và xóa card mạng ảo đã tạo ra, bạn chạy đoạn script dưới đây.

```sh
#!/bin/bash

####################################
# Tear Down Ethernet bridge on Linux
####################################

# Define Bridge Interface
br="br0"

# Define list of TAP interfaces to be bridged together
tap="tap0"

ifconfig $br down
brctl delbr $br

for t in $tap; do
    openvpn --rmtun --dev $t
done
```
#5. Tài liệu tham khảo
- https://openvpn.net/index.php/open-source/documentation/miscellaneous/76-ethernet-bridging.html
- http://www.evilbox.ro/linux/install-bridged-openvpn-on-ubuntu-14-04-x64-server-and-configure-windows-8-1-x64-client/