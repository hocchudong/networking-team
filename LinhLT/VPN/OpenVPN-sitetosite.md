#OpenVPN site to site

#1. Mô hình
![](http://i.imgur.com/szVrl53.jpg)

- Site A:
	- ip public: 10.10.40.131
	- ip lan private: 10.10.10.134
- Site B:
	- ip public: 10.10.40.132
	- ip lan private: 10.10.20.137

#2. Thực hiện
##2.1 Các bước đầu tiên, thực hiện ở cả 2 server.
- Cấu hình Firewall: Mặc định firewall mở các port 8001 và cho phép tất cả gói tin đi vào, chuyển tiếp.

- Cho phép routing: sửa file `/etc/sysctl.conf` và bỏ comment ở dòng này.
```sh
net.ipv4.ip_forward = 1
```
##2.2 Cấu hình file `/etc/openvpn/server.conf`
###2.2.1 Trên site A.

```sh
remote 10.10.40.132
float
port 8001
dev tun
ifconfig 10.0.0.1 10.0.0.2
persist-tun
persist-local-ip
persist-remote-ip
comp-lzo
ping 15
secret /etc/openvpn/vpn.key
route 10.10.20.0 255.255.255.0
chroot /tmp/openvpn
user nobody
group nogroup
log-append /var/log/openvpn/vpn.log
verb 1
```

###2.2.2 Trên site B

```sh
remote 10.10.40.131
float
port 8001
dev tun
ifconfig 10.0.0.2 10.0.0.1
persist-tun
persist-local-ip
persist-remote-ip
comp-lzo
ping 15
secret /etc/openvpn/vpn.key
route 10.10.10.0 255.255.255.0
chroot /tmp/openvpn
user nobody
group nogroup
log-append /var/log/openvpn/vpn.log
verb 1
```

- Giải thích các thông số:

|Lệnh|Ý nghĩa|
|:---:|:---:|
|remote 10.10.40.131| Địa chỉ ip của server phía bên kia cần kết nối|
|port 8001|port kết nối tạo tunnel|
|dev tun|tạo card mạng ảo tên tun dùng để tạo tunnel|
|ifconfig 10.0.0.2 10.0.0.1| đặt ip cho card mạng ảo vừa tạo ở trên. ở đây, 10.0.0.2 sẽ là ip của card mạng ảo trên site B và 10.0.0.1 là ip card mạng ảo trên site A|.
|secret /etc/openvpn/vpn.key| Chỉ ra đường dẫn file key để xác thực kết nối|
|route 10.10.10.0 255.255.255.0| Thêm dải mạng lanprivate của site bên kia vào bảng định tuyến|
|log-append /var/log/openvpn/vpn.log| Chỉ ra đường dẫn file log|


##2.3 Tạo key
- Tiến hành tạo key trên site A và sao chép key vừa tạo sang site B.
- Lệnh tạo key
```sh
openvpn --genkey --secret /etc/openvpn/vpn.key
```

- Sau đó, ta sao chép file key này sang site B.
```sh
scp /etc/openvpn/vpn.key root@10.10.40.132:/etc/openvpn/vpn.key
```

- Khởi động lại dịch vụ openvpn
```sh
service openvpn restart
```

#3. Kết quả.
- Thực hiện lệnh Ping từ Client 1 sang client 2:
![](http://image.prntscr.com/image/39c0f7d8b2904a558d21e8b39bd12b60.png)

- Sử dụng máy đứng giữa đường truyền để bắt gói tin
![](http://image.prntscr.com/image/95ccf510ee7942a48fe22efb1936136d.png)
#4. Tài liệu tham khảo
http://zeldor.biz/2010/12/openvpn-site-to-site-setup/
