#LAB point to point bridge
#1. Mô hình

network lan ------vpnserver -----internet--------vpnclient --- network lan

Tunnel-layer

.............10.10.10.135 - br0 =============vpn==================br0 - 10.10.10.137.........

Ip-adresses

....10.10.10.135/Eth1--Eth0/172.16.69.133----internet----172.16.69.136/Eth0--Eth1/10.10.10.137..

Internal networks

10.10.10.0.............................................................10.10.10.0

#2. Các bước chuẩn bị 
- Cho phép chuyển tiếp gói tin: Chỉnh sửa file `/etc/sysctl.conf`, enable dòng sau:
```sh
net.ipv4.ip_forward = 1
```
- Cài đặt các gói cần thiết.
```sh
apt-get install bridge-utils openvpn easy-rsa
```
#3. Tạo bridge
##3.1 Trên server.
- Tạo tap0
```sh
openvpn --mktun --dev tap0
```
- Tạo bridge
```sh
brctl addbr br0
brctl addif br0 eth1
brctl addif br0 tap0
ifconfig eth1 0.0.0.0 up
ifconfig tap0 0.0.0.0 up
ifconfig br0 10.10.10.135 netmask 255.255.255.0 up
```
- Kiểm tra
```sh
root@adk:/etc/openvpn# brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.000c2949de13       no              eth1
                                                        tap0
```

```sh
root@adk:/etc/openvpn# ifconfig -a
br0       Link encap:Ethernet  HWaddr 00:0c:29:49:de:13  
          inet addr:10.10.10.135  Bcast:10.10.10.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fe49:de09/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:9252775 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1061 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:1347308329 (1.3 GB)  TX bytes:172211 (172.2 KB)

eth0      Link encap:Ethernet  HWaddr 00:0c:29:49:de:09  
          inet addr:172.16.69.133  Bcast:172.16.69.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fe49:de09/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:4783769 errors:0 dropped:0 overruns:0 frame:0
          TX packets:4452867 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:1086408965 (1.0 GB)  TX bytes:1141760574 (1.1 GB)

eth1      Link encap:Ethernet  HWaddr 00:0c:29:49:de:13  
          inet6 addr: fe80::20c:29ff:fe49:de13/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:4471491 errors:0 dropped:0 overruns:0 frame:0
          TX packets:4494664 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:782636643 (782.6 MB)  TX bytes:682428686 (682.4 MB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:9 errors:0 dropped:0 overruns:0 frame:0
          TX packets:9 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:1108 (1.1 KB)  TX bytes:1108 (1.1 KB)

tap0      Link encap:Ethernet  HWaddr 7e:6a:71:b9:69:13  
          inet6 addr: fe80::7c6a:71ff:feb9:6913/64 Scope:Link
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:4782408 errors:0 dropped:0 overruns:0 frame:0
          TX packets:4452145 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100 
          RX bytes:694303648 (694.3 MB)  TX bytes:781398651 (781.3 MB)
```

##3.2 Trên client.
- Tạo tap0
```sh
openvpn --mktun --dev tap0
```
- Tạo bridge
```sh
brctl addbr br0
brctl addif br0 eth1
brctl addif br0 tap0
ifconfig eth1 0.0.0.0 up
ifconfig tap0 0.0.0.0 up
ifconfig br0 10.10.10.137 netmask 255.255.255.0 up
```
- Kiểm tra
```sh
root@adk:/etc/openvpn# brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.000c29a4a8ca       no              eth1
                                                        tap0
```

```sh
root@adk:/etc/openvpn# ifconfig -a
br0       Link encap:Ethernet  HWaddr 00:0c:29:a4:a8:ca  
          inet addr:10.10.10.137  Bcast:10.10.10.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fea4:a8c0/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:9165409 errors:0 dropped:0 overruns:0 frame:0
          TX packets:314736 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:1348505931 (1.3 GB)  TX bytes:13355679 (13.3 MB)

eth0      Link encap:Ethernet  HWaddr 00:0c:29:a4:a8:c0  
          inet addr:172.16.69.136  Bcast:172.16.69.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fea4:a8c0/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:4453648 errors:0 dropped:0 overruns:0 frame:0
          TX packets:4783459 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:1143266618 (1.1 GB)  TX bytes:1084949855 (1.0 GB)

eth1      Link encap:Ethernet  HWaddr 00:0c:29:a4:a8:ca  
          inet6 addr: fe80::20c:29ff:fea4:a8ca/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:4713974 errors:0 dropped:0 overruns:0 frame:0
          TX packets:4470266 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:695483148 (695.4 MB)  TX bytes:782653253 (782.6 MB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:25 errors:0 dropped:0 overruns:0 frame:0
          TX packets:25 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:2724 (2.7 KB)  TX bytes:2724 (2.7 KB)

tap0      Link encap:Ethernet  HWaddr 42:e6:4a:3b:05:a9  
          inet6 addr: fe80::40e6:4aff:fe3b:5a9/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:4452139 errors:0 dropped:0 overruns:0 frame:0
          TX packets:4782443 errors:0 dropped:7624 overruns:0 carrier:0
          collisions:0 txqueuelen:100 
          RX bytes:781398143 (781.3 MB)  TX bytes:694310426 (694.3 MB)

```

#4. Cấu hình server và client.
Chọn 1 trong 2 cách sau, dùng static key hoặc dung cert.
##4.1 Dùng static key
###4.1.1 Trên server
- Gen key trên server.
```sh
cd /etc/openvpn/
openvpn --genkey --secret secret.key
```

- Copy key sang client.
```sh
scp /etc/openvpn/secret.key root@172.16.69.136:/etc/openvpn/
```

- File `/etc/openvpn/server.conf`
```sh
local 172.16.69.133
remote 172.16.69.136
port 1194
secret secret.key 0
proto udp
dev tap0
keepalive 10 120
comp-lzo
persist-key
persist-tun
status openvpn-status.log
verb 3
```

###4.1.2 Trên client
- File `/etc/openvpn/client.conf`
```sh
local 172.16.69.136
remote 172.16.69.133
port 1194
secret secret.key 1
proto udp
dev tap0
keepalive 10 120
comp-lzo
persist-key
persist-tun
status openvpn-status.log
verb 3
```
##4.2 Dùng cer.
###4.2.1 Trên server

- copy thư mục easy-rsa vào /etc/openvpn/
```sh
make-cadir /etc/openvpn/easy-rsa
```
- Chỉnh sửa các thông số:
```sh
vi /etc/openvpn/easy-rsa/vars
```

```sh
export KEY_COUNTRY="VN"
export KEY_PROVINCE="HaNoi"
export KEY_CITY="HaDong"
export KEY_ORG="VNPT"
export KEY_EMAIL="admin@vnpt.vn"
export KEY_OU="VNPTDATA"

# X509 Subject Field
export KEY_NAME="server"
```

- Tạo key cho server
```sh
cd /etc/openvpn/easy-rsa/
source vars
./clean-all
./build-dh
./build-ca
./build-key-server server
cd keys
openvpn --genkey --secret ta.key
```

- Tạo key cho client.
```sh
cd /etc/openvpn/easy-rsa/
./build-key client
```

- Chép cer sang client:
```sh
cd /etc/openvpn/easy-rsa/keys/
ca.crt  client.crt  client.key  dh2048.pem  ta.key
```

- File `/etc/openvpn/server.conf`
```sh
local 172.16.69.133
remote 172.16.69.136
port 1194
proto udp
dev tap0
tls-server
ca /etc/openvpn/easy-rsa/keys/ca.crt
cert /etc/openvpn/easy-rsa/keys/server.crt
key /etc/openvpn/easy-rsa/keys/server.key  # This file should be kept secret
dh /etc/openvpn/easy-rsa/keys/dh2048.pem
keepalive 10 120
tls-auth /etc/openvpn/easy-rsa/keys/ta.key 0 # This file is secret
comp-lzo
persist-key
persist-tun
status openvpn-status.log
verb 3
```

###4.2.2 Trên client
- File `/etc/openvpn/client.conf`
```sh
local 172.16.69.136
remote 172.16.69.133
port 1194
proto udp
dev tap0
tls-client
ca ca.crt
cert client.crt
key client.key  # This file should be kept secret
dh dh2048.pem
keepalive 10 120
tls-auth ta.key 1 # This file is secret
comp-lzo
persist-key
persist-tun
status openvpn-status.log
verb 3
```

##5. Kết quả.
- static key
![](http://image.prntscr.com/image/b2954ac34f9341efb04f6c0feaa8c40d.png)

- cer
![](http://image.prntscr.com/image/b2007bfaa6ad4b3695251d63bc6c9f4e.png)