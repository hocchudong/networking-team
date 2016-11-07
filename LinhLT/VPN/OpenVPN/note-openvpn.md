#Note OpenVPN
- OpenVPN sử dụng giao thức SSL/TLS để bảo vệ kết nối.
- OpenVPN sử dụng virtual network adapter (tun hoặc tap) để giao tiếp giữa OpenVPN và hệ điều hành.
- OpenVPN có 2 khái niệm là control channel và data channel, cả hai đều được mã hoá. Tất cả các traffic đều
đi qua kết nối UDP hoặc TCP (tuỳ bạn cấu hình). 
    - control channel: Sử dụng giao thức SSL/TLS để mã hoá.
    - data channel: Sử dụng giao thức mã hoá được cấu hình để mã hoá.
- Mặc định: OpenVPN sử dụng giao thức UDP và port 1194

#1. tun/tap driver
- Tun device: Dùng trong routing.
- Tap device: Dùng trong bridge.


![](http://image.prntscr.com/image/b7dcbda17b874036b078ac08c8150619.png)

#2. Point to Point mode:
- point-to-point mode using pre-shared keys
- The secret key is used by OpenVPN for both encrypting and authenticating (signing) each packet.
- Gen static key: 
```sh
openvpn --genkey --secret secret.key
```
## 2.1 Ví dụ: 

![](http://image.prntscr.com/image/05893aa753fc40c8a363ad99db8c3cfc.png)

- server: `movpn-02-02-server.conf`
```sh
dev tun
proto udp
local openvpnserver.example.com
remote openvpnclient.example.com
port 1194
secret secret.key 0
ifconfig 10.200.0.1 10.200.0.2
route 192.168.4.0 255.255.255.0
#tun-ipv6
#ifconfig-ipv6 2001:610:120::200:0:1 2001:610:120::200:0:2
user nobody
group nobody # use 'group nogroup' on Debian/Ubuntu
persist-tun
persist-key
keepalive 10 60
ping-timer-rem
verb 3
daemon
log-append /var/log/openvpn.log
```

- client: `movpn-02-02-client.conf`
```sh
dev tun
proto udp
local openvpnclient.example.com
remote openvpnserver.example.com
port 1194
secret secret.key 1
ifconfig 10.200.0.2 10.200.0.1
route 192.168.122.0 255.255.255.0
#tun-ipv6
#ifconfig-ipv6 2001:610:120::200:0:2 2001:610:120::200:0:1
[ 43 ]Point-to-point Mode
user nobody
group nobody # use 'group nogroup' on Debian/Ubuntu
persist-tun
persist-key
keepalive 10 60
ping-timer-rem
verb 3
daemon
log-append /var/log/openvpn.log
```

- Giải thích các thông số: 
    - dev tun: Dùng tun device.
    - proto udp: Dùng giao thức udp.
    - local: Địa chỉ ip mà OpenVPN sẽ lắng nghe `incoming connections`. Nếu không khai báo, mặc định OpenVPN sẽ
        lắng nghe trên tất cả các interfaces. 
    - remote: Địa chỉ ip từ xa mà OpenVPN sẽ đồng ý các incoming connections. Nếu không khai báo, mặc định OpenVPN sẽ
        lắng nghe trên tất cả các địa chỉ ip.
    - port: Port dùng để kết nối. Mặc định là 1194.
    - secret secret.key 0: chỉ định file static key. Giá trị 0 được dùng cho server và 1 cho client. 
    - ifconfig 10.200.0.1 10.200.0.2: Đặt địa chỉ ip cho tun. 10.200.0.1 sẽ là ip thuộc local và 10.200.0.2 sẽ thuộc remote.
    - route 192.168.4.0 255.255.255.0: route mạng của máy remote. Cho phép các máy thuộc bên server có thể nhìn thấy các máy lan thuộc remote.
    - tun-ipv6: Tạo tun device với ipv6
    - ifconfig-ipv6 2001:610:120::200:0:1 2001:610:120::200:0:2: Đặt địa chỉ ipv6 cho tun.
    - persist-tun / persist-key: Không tạo lại tun hay tạo key mới khi tunnel bị khởi động lại.
    - keepalive 10 60 / ping-timer-rem: Đảm bảo kết nối vpn vẫn up ngay cả khi không có traffic trong tunnel.

- Chạy OpenVPN
```sh
[root@server] # openvpn --config movpn-02-02-server.conf
[root@client] # openvpn --config movpn-02-02-client.conf
```

##2.2 Bridged tap adapter on both ends

![](http://image.prntscr.com/image/ae204b0c21f04a2fb61fe8968c7db8fd.png)

- Tạo tap device trên cả client và servẻ
```sh
# openvpn --mktun --dev tap0
Thu Sep 11 16:57:30 2014 TUN/TAP device tap0 opened
Thu Sep 11 16:57:30 2014 Persist state set to: ON
```
- Tạo bridge trên client.
```sh
brctl addbr br0
# brctl addif br0 eth0
# brctl addif br0 tap0
# ifconfig eth0 0.0.0.0 up
# ifconfig tap0 0.0.0.0 up
# ifconfig br0 192.168.4.128 netmask 255.255.255.0 up
```

- Tạo bridge trên server tương tự như client, chú ý phần địa chỉ ip.

- Kiểm tra bridge: 
```sh
# brctl show
bridge name     bridge id           STP enabled     interfaces
br0             8000.5c260a307224   no              eth0
                                                    tap0
```

```sh
# ifconfig -a
br0     Link encap:Ethernet
        HWaddr 5C:26:0A:30:72:24
        inet addr:192.168.4.128
        Mask:255.255.255.0
        Bcast:192.168.4.255
        UP BROADCAST RUNNING MULTICAST
        MTU:1500
        Metric:1
        RX packets:4 errors:0 dropped:0 overruns:0 frame:0
        TX packets:10 errors:0 dropped:0 overruns:0 carrier:0
        collisions:0 txqueuelen:0
        RX bytes:244 (244.0 b)
        
eth0    Link encap:Ethernet
        TX bytes:732 (732.0 b)
        HWaddr 5C:26:0A:30:72:24
        UP BROADCAST RUNNING MULTICAST
        MTU:1500
        Metric:1
        RX packets:2087 errors:0 dropped:0 overruns:0 frame:0
        TX packets:2427 errors:0 dropped:0 overruns:0 carrier:0
        collisions:0 txqueuelen:1000
        RX bytes:203516 (198.7 KiB)
        TX bytes:231571 (226.1 KiB)
        Interrupt:20 Memory:f5400000-f5420000

tap0    Link encap:Ethernet
        HWaddr CA:85:1E:AE:AF:59
        [ 55 ]Point-to-point Mode
        UP BROADCAST RUNNING MULTICAST
        MTU:1500
        Metric:1
        RX packets:0 errors:0 dropped:0 overruns:0 frame:0
        TX packets:0 errors:0 dropped:11 overruns:0 carrier:0
        collisions:0 txqueuelen:100
        RX bytes:0 (0.0 b)
        TX bytes:0 (0.0 b)
```

- Tạo file `movpn-02-05.conf`, giống nhau trên cả 2 site.
```h
dev tap0
secret secret.key
verb 3
daemon
log-append /var/log/openvpn.log
...............
```

- Chạy OpenVPN
```sh
[root@server] # openvpn --config movpn-02-05.conf \
--remote openvpnclient.example.com
[root@client] # openvpn --config movpn-02-05.conf \
--remote openvpnserver.example.com
```

- Nếu bạn muốn xoá Bridges, chạy lệnh sau
```sh
# ifconfig br0 down
# brctl delif br0 tap0
# brctl delif br0 eth0
# brctl delbr br0
# openvpn --rmtun --dev tap0
Thu Sep 11 18:55:22 2014 TUN/TAP device tap0 opened
Thu Sep 11 18:55:22 2014 Persist state set to: OFF
```

##2.3 Combining point-to-point mode with certificates
- Tạo certificates
- Cấu hình `server.conf`
```sh
proto udp
port 1194
dev tun
tls-server
ifconfig 10.200.0.1 10.200.0.2
tls-auth /etc/openvpn/movpn/ta.key 0
dh /etc/openvpn/movpn/dh2048.pem
ca /etc/openvpn/movpn/movpn-ca.crt
cert /etc/openvpn/movpn/server.crt
key /etc/openvpn/movpn/server.key
persist-key
persist-tun
keepalive 10 60
user
nobody
group nobody # use 'group nogroup' on Debian/Ubuntu
verb 3
daemon
log-append /var/log/openvpn.log
```

- **Thông số tương tự như các bài trên, tuy nhiên các bạn cần chú ý các tham số sau: **
    - tls-server: chỉ định là tls server. **Lệnh quan trọng**.
    - dh, ca, cert, key: Chỉ định đường dẫn của các file tương ứng.


- Cấu hình `client.conf`:
```sh
port 1194
dev tun
tls-client
ifconfig 10.200.0.2 10.200.0.1
remote openvpnserver.example.com
remote-cert-tls server
tls-auth /etc/openvpn/movpn/ta.key 1
ca /etc/openvpn/movpn/movpn-ca.crt
cert /etc/openvpn/movpn/client1.crt
key /etc/openvpn/movpn/client1.key
persist-key
persist-tun
keepalive 10 60
user
nobody
group nobody
# use 'group nogroup' on Debian/Ubuntu
verb 3
daemon
log-append /var/log/openvpn.log
```
- **Các thông số tương tự server, chỉ khác mỗi thông số `tls-client` (Lệnh quan trọng)** .

#3. Client/Server Mode with tun Devices
- Server có thể xử lý nhiều client connect đến.
- Mỗi client sẽ nhận được 1 địa chỉ ip từ dải địa chỉ ip mà VPN server quản lý.

Phần này mình sẽ giải thích các thông số file cấu hình, đồng thời nêu lên trường hợp áp dụng các thông số này.
Các bạn chú ý là phần cấu hình server-client khác với point-to-point. Những dòng cấu hình dưới dấy CHỈ THUỘC về
mô hình server-client. Mình sẽ lấy ví dụ và giải thích cấu hình.

#3.1 Ví dụ:

![](http://image.prntscr.com/image/8e16835b1c3b4f4291678eb134f7439c.png)


- `server.conf`
```sh
proto udp
port 1194
dev tun
server 10.200.0.0 255.255.255.0
push “route 192.168.122.0 255.255.255.0”
persist-key
persist-tun
keepalive 10 60
dh /etc/openvpn/movpn/dh2048.pem
ca /etc/openvpn/movpn/movpn-ca.crt
cert /etc/openvpn/movpn/server.crt
key /etc/openvpn/movpn/server.key
tls-auth /etc/openvpn/movpn/ta.key 0
client-to-client
ifconfig-pool-persist ipp.txt
user nobody
group nobody
# use ‘group nogroup’ on Debian/Ubuntu
verb 3
daemon
log-append /var/log/openvpn.log
```

- `client.conf`
```sh
client
proto udp
remote openvpnserver.example.com
port 1194
dev tun
nobind
ca /etc/openvpn/movpn/movpn-ca.crt
cert /etc/openvpn/movpn/client1.crt
key /etc/openvpn/movpn/client1.key
tls-auth /etc/openvpn/movpn/ta.key 1
```

- Giải thích:
    - server 10.200.0.0 255.255.255.0: Đây là dải địa chỉ sẽ được dùng cho server và client. Mặc định thì 
        server sẽ dùng 10.200.0.1 và client đầu tiên sẽ dùng 10.200.0.2. Việc cấp địa chỉ ip tuân thủ theo
        nguyên tắc `topology subnet`.
    - push “route 192.168.122.0 255.255.255.0”: Đẩy mạng subnet kết nối với server, đến client.
    - client: Xác định máy hiện tại là client.
    - nobind: client sẽ không bind và listen trên port được chỉ định.
    - tls-auth key: Sử dụng tls-auth key
    - client-to-client: Cho phép các client khi kết nối đến server sẽ nói chuyện được với nhau thông quan server.
    - ifconfig-pool-persist ipp.txt: File ipp.txt sẽ lưu giữ các ip của từng client khi kết nối thành công. Để từ đó,
        nếu client bị mất kết nối thì sau khi kết nối lại, nó sẽ nhận được địa chỉ ip trước đó đã kết nối.

#3.2 CCD files
- Tuỳ chọn `client-config-dir` cho phép cho ta cấu hình một số tính năng cho từng client (mỗi client tạo 1 file có tên là tên của client khi cài đặt chứng chỉ) như:
    - gán ip cho từng client. 
    - routing subnet client to the server
    - ....
- Ví dụ: 
```sh
ifconfig-push 10.200.0.99 255.255.255.0     #topology net30
iroute 192.168.4.0 255.255.255.0
push “route 192.168.122.0 255.255.255.0”
```
- Giải thích:
    - ifconfig-push: Gán ip tĩnh cho client.
    - iroute: Routing mạng lan của client đến server.
    - push "route ": Routing mạng lan của server đến client.

##3.3 Client-side routing

![](http://image.prntscr.com/image/a8d47e7484a543dcbdb839a7b76e41be.png)

- `server.conf`
```sh
...........
client-config-dir /etc/openvpn/movpn/clients
route 192.168.4.0 255.255.255.0 10.200.0.1 #route mạng 192.168.4.0/24 qua gateway 10.200.0.1
...........

```
- `CCD file`
```sh
ifconfig-push 10.200.0.99 255.255.255.0     #topology net30
iroute 192.168.4.0 255.255.255.0
push “route 192.168.122.0 255.255.255.0”
```

#4. Client/Server Mode with tap Devices
##4.1 Bridging on Linux
![](http://image.prntscr.com/image/f123def66b1c4d58a7cf28f62481ad84.png)

- Tạo bridge với scripts dưới đây.
```sh
#!/bin/bash
br="br0"
tap="tap0"
eth="eth0"
br_ip="192.168.122.1"
br_netmask="255.255.255.0"
br_broadcast="192.168.122.255"
# Create the tap adapter
openvpn --mktun --dev $tap
# Create the bridge and add interfaces
brctl addbr $br
brctl addif $br $eth
brctl addif $br $tap
# Configure the bridge
ifconfig $tap 0.0.0.0 promisc up
ifconfig $eth 0.0.0.0 promisc up
ifconfig $br $br_ip netmask $br_netmask broadcast $br_broadcast
```

- Cấu hình `server.conf`
```sh
tls-server
proto udp
port 1194
dev tap0 ## the '0' is extremely important
server-bridge 192.168.122.1 255.255.255.0 192.168.122.128 192.168.122.200
remote-cert-tls client
tls-auth /etc/openvpn/movpn/ta.key 0
dh /etc/openvpn/movpn/dh2048.pem
ca /etc/openvpn/movpn/movpn-ca.crt
cert /etc/openvpn/movpn/server.crt
key /etc/openvpn/movpn/server.key
persist-key
persist-tun
keepalive 10 60
user nobody
group nobody
verb 3
daemon
log-append /var/log/openvpn.log
```
- Giải thích: 
    - server-bridge network gateway, subnet mask, pool start, and pool end. The pool addresses are those that can be assigned to clients.
        - 192.168.122.1 255.255.255.0 : Địa chỉ gateway vpn.
        - 192.168.122.128 192.168.122.200: Dải địa chỉ sẽ cấp cho client.

- Để xoá bridge đã tạo, chạy đoạn scripts sau:
```sh
ifconfig br0 down
brctl delif br0 eth0
brctl delif br0 tap0
brctl delbr br0
openvpn --rmtun --dev tap0
```

## Đặt password xác thực.
- Trong file cấu hình `server.conf`, thêm dòng sau:
```sh
# Add an extra username/password authentication for clients
plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so login
```
- Tạo username và password để xác thực. Client sẽ nhập trước khi muốn kết nối.
```sh
# Create a user account with no home directory and shell access.
sudo useradd 97228 -M -s /bin/false
sudo passwd 97228
```
- Một số tuỳ chọn:
```sh
client-to-client    #Cho phép các client khi kết nối đến server sẽ nói chuyện được với nhau thông qua server.
duplicate-cn        #Mặc định những user khác nhau sẽ phải dùng cert cho từng user. Khi tuỳ chọn này được bật, nó cho phép nhiều user chỉ dùng 1 cert cũng có thể nối được.
```



#5. Tổng kết.
Các vấn đề chốt lại là:
- OpenVPN sử dụng nền tảng SSL/TLS để đảm bảo toàn, mặc định dùng udp và port 1194.
- OpenVPN tạo tunnel kết nối. (point to point hoặc server-client.)
- Ở chế đố point to point, 2 điểm cần cấu hình giá trị remote.(ip của điểm bên kia).
- Point to point có thể dùng static key hoặc certificates.
- Một số lệnh cấu hình ở mode server-client sẽ không chạy được ở mode point to point:
    - server 10.200.0.0 255.255.255.0: Dải ip cấp cho tunnel. Mặc định server dùng **.1**.
    - push “route 192.168.122.0 255.255.255.0”: Đẩy mạng subnet kết nối với server, đến client.
    - client: Xác định máy hiện tại là client.
    - client-to-client: Cho phép các client khi kết nối đến server sẽ nói chuyện được với nhau thông quan server.
    - client-config-dir ccd: Cấu hình riêng biệt cho từng client.
        - ifconfig-push 10.200.0.99 255.255.255.0   #topology net30
        - iroute 192.168.4.0 255.255.255.0          #Lan network connect client.  
        - push “route 192.168.122.0 255.255.255.0”  #Lan network connect server.
- tun device dùng trong routing và tap device dùng trong bridge.
- Muốn chạy bridge phải dùng gói `bridge-utils` để tạo bridge: 
    - Tạo bridge. Tạo tap0. Kết nối tap0 và interfaces public (eth0) vào bridge vừa tạo. Bỏ ip eth0, gán ip này cho bridge.
- Bridge trong chế độ server-client có dòng cấu hình (trong point to point không có):
    - server-bridge network gateway, subnet mask, pool start, and pool end.
- Từng trường hợp cụ thể sẽ được lab. Các bài lab tìm trong thư mục này.

#6. Tham khảo
- Sách **Mastering OpenVPN: Master building and integrating secure private networks using OpenVPN** bởi hai tác giả
**Eric F Crist** và **Jan Just Keijser**.
- Sách này được up trong thư mục này.
