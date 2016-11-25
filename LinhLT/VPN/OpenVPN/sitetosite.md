#OpenVPN site to site

#1. Mô hình
![](http://i.imgur.com/szVrl53.jpg)

- Site A (Server):
	- ip public: 10.10.40.131
	- ip lan private: 10.10.10.134
- Site B (Client):
	- ip public: 10.10.40.132
	- ip lan private: 10.10.20.137

#2. Các bước chuẩn bị
- Cấu hình Firewall: Mặc định firewall mở các port 1194 và cho phép tất cả gói tin đi vào, chuyển tiếp.

- Cho phép routing: sửa file `/etc/sysctl.conf` và bỏ comment ở dòng này.
```sh
net.ipv4.ip_forward = 1
```
- - Cài đặt các gói cần thiết.
```sh
apt-get install openvpn easy-rsa
```
#3. Cấu hình site A và site B.
Chọn 1 trong 2 cách sau, dùng static key hoặc dung cert.
##3.1 Dùng static key
###3.1.1 Trên site A
- Gen key trên site A.
```sh
openvpn --genkey --secret vpn.key
```

- Copy key sang site B.
```sh
scp vpn.key root@10.10.40.132:/etc/openvpn/
```

- File `serverA.conf`
```sh
local 10.10.40.131
remote 10.10.40.132
port 1194
proto udp
dev tun
ifconfig 10.0.0.1 10.0.0.2
persist-tun
persist-local-ip
persist-remote-ip
comp-lzo
ping 15
secret /etc/openvpn/vpn.key 0
route 10.10.20.0 255.255.255.0
user nobody
group nogroup
log-append /var/log/openvpn/vpn.log
verb 1
```

###3.1.2 Trên site B
- File `serverB.conf`
```sh
local 10.10.40.132
remote 10.10.40.131
port 1194
proto udp
dev tun
ifconfig 10.0.0.2 10.0.0.1
persist-tun
persist-local-ip
persist-remote-ip
comp-lzo
ping 15
secret /etc/openvpn/vpn.key 1
route 10.10.10.0 255.255.255.0
user nobody
group nogroup
log-append /var/log/openvpn/vpn.log
verb 1
```

- Giải thích các thông số:

|Lệnh|Ý nghĩa|
|:---:|:---:|
|remote 10.10.40.131| Địa chỉ ip của server phía bên kia cần kết nối|
|port 1194|port kết nối tạo tunnel|
|dev tun|tạo card mạng ảo tên tun dùng để tạo tunnel|
|ifconfig 10.0.0.2 10.0.0.1| đặt ip cho card mạng ảo vừa tạo ở trên. ở đây, 10.0.0.2 sẽ là ip của card mạng ảo trên site B và 10.0.0.1 là ip card mạng ảo trên site A|.
|secret /etc/openvpn/vpn.key| Chỉ ra đường dẫn file key để xác thực kết nối|
|route 10.10.10.0 255.255.255.0| Thêm dải mạng lanprivate của site bên kia vào bảng định tuyến|
|log-append /var/log/openvpn/vpn.log| Chỉ ra đường dẫn file log|


- Khởi động lại dịch vụ openvpn trên cả 2 server.
```sh
service openvpn restart
```

##3.2 Dùng cer.
###3.2.1 Trên site A
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

- File `/etc/openvpn/siteA.conf`: 
```sh
local 10.10.40.131
remote 10.10.40.132
port 1194
proto udp
dev tun
ifconfig 10.0.0.1 10.0.0.2
persist-tun
persist-local-ip
persist-remote-ip
comp-lzo
ping 15
tls-server
ca /etc/openvpn/easy-rsa/keys/ca.crt
cert /etc/openvpn/easy-rsa/keys/server.crt
key /etc/openvpn/easy-rsa/keys/server.key  # This file should be kept secret
dh /etc/openvpn/easy-rsa/keys/dh2048.pem
tls-auth /etc/openvpn/easy-rsa/keys/ta.key 0 # This file is secret
route 10.10.20.0 255.255.255.0
user nobody
group nogroup
log-append /var/log/openvpn/vpn.log
verb 1
```

- Bổ sung các tham số khác so với dùng static key là: 
	- tls-server.
	- ca, cert,key,dh: 
- Bỏ đi tham số:
	- secret 

###3.2.2 Trên site B
- File `serverB.conf`
```sh
local 10.10.40.132
remote 10.10.40.131
port 1194
proto udp
dev tun
ifconfig 10.0.0.2 10.0.0.1
persist-tun
persist-local-ip
persist-remote-ip
comp-lzo
ping 15
tls-client
ca ca.crt
cert client.crt
key client.key  # This file should be kept secret
dh dh2048.pem
tls-auth ta.key 1 # This file is secret
route 10.10.10.0 255.255.255.0
user nobody
group nogroup
log-append /var/log/openvpn/vpn.log
verb 1
```
- Bổ sung các tham số khác so với dùng static key là: 
	- tls-client.
	- ca, cert,key,dh: 
- Bỏ đi tham số:
	- secret 

#4. Kết quả.
- Thực hiện lệnh Ping từ Client 1 sang client 2:
![](http://image.prntscr.com/image/39c0f7d8b2904a558d21e8b39bd12b60.png)

- Sử dụng máy đứng giữa đường truyền để bắt gói tin
![](http://image.prntscr.com/image/95ccf510ee7942a48fe22efb1936136d.png)
#5. Tài liệu tham khảo
- http://zeldor.biz/2010/12/openvpn-site-to-site-setup/
- https://www.hanscees.com/sme7/openvpnsitetositetunnelsme7.html