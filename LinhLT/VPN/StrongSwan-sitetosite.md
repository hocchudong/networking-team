#StrongSwan site to site
#1. Mô hình
![](http://i.imgur.com/iYMHmo2.jpg)

- Site A:
	- ip public: 10.10.40.134
	- ip lan private: 10.10.10.137
- Site B:
	- ip public: 10.10.40.135
	- ip lan private: 10.10.20.138

#2. Thực hiện.
##2.1 Cài đặt các bước ban đầu.
- Cài đặt StrongSwan
```sh
apt-get install strongswan
```

- Cho phép chuyển tiếp IP và vô hiệu hóa trang chuyển hướng vĩnh viễn bằng cách: 

Sửa file `/etc/sysctl.conf` , tìm và bỏ comment các dòng sau :

```sh
net.ipv4.ip_forward = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
```

- reload `/etc/sysctl.conf`:
```sh
sysctl -p
```

- Thiết lập rules của Iptables cho phép các gói tin đi qua:

```sh
iptables -A INPUT -p udp --dport 500 -j ACCEPT
iptables -A INPUT -p tcp --dport 4500 -j ACCEPT
iptables -A INPUT -p udp --dport 4500 -j ACCEPT
```

##2.2 Cấu hình ipsec: `vi /etc/ipsec.conf`
###2.2.1 Trên site A.

```sh
root@adk:~# cat /etc/ipsec.conf
# ipsec.conf - strongSwan IPsec configuration file
conn sitea-to-siteb
    authby=secret
    ikelifetime=60m
    keylife=20m
    rekeymargin=3m
    keyingtries=1
    mobike=no
    keyexchange=ikev1
    auto=route
    esp=aes128-sha1-modp1024!
    ike=aes128-sha1-modp1024!
    left=10.10.40.134
    right=10.10.40.135
    leftauth=psk
    rightauth=psk
    leftsubnet=10.10.10.0/24
    rightsubnet=10.10.20.0/24
    aggressive=no
    dpdtimeout=120s
    type=tunnel
```

###2.2.2 Trên site B.

```sh
root@adk:~# cat /etc/ipsec.conf
# ipsec.conf - strongSwan IPsec configuration file

conn siteb-to-sitea
    authby=secret
    ikelifetime=60m
    keylife=20m
    rekeymargin=3m
    keyingtries=1
    mobike=no
    keyexchange=ikev1
    auto=route
    esp=aes128-sha1-modp1024!
    ike=aes128-sha1-modp1024!
    left=10.10.40.135
    right=10.10.40.134
    leftauth=psk
    rightauth=psk
    leftsubnet=10.10.20.0/24
    rightsubnet=10.10.10.0/24
    aggressive=no
    dpdtimeout=120s
    type=tunnel
```

Giải thích các thông số. Các thông số này tương tự trong phần cấu hình OpenSwan. Các bạn có thể
tham khảo tại đây: https://github.com/lethanhlinh247/networking-team/blob/master/LinhLT/VPN/OpenSwan-sitetosite.md



##2.3 Cấu hình xác thực
- Tạo Pre-Share-Key (PSK). PSK trên 2 server phải giống nhau.
- Đường dẫn file chứa PSK `/etc/ipsec.secrets`.


```sh
root@adk:~# vi /etc/ipsec.secrets
ip-public-site1  ip-publici-site2 :  PSK  "123456a@"
```
- Hoặc chúng ta có thể tạo PSK cho mọi tunnel với nội dung sau:
```sh
%any %any : PSK "123456a@"
```

- Ở đây, tôi đã cấu hình với site A:
```sh
10.10.40.134    10.10.40.135 :  PSK  "123456a@"
```

- Tương tự, với site B.
```sh
10.10.40.135    10.10.40.134 :  PSK  "123456a@"
```

- Khởi động lại ipsec
```
ipsec restart
```

- Kiểm tra trạng thái hoạt động
```sh
root@adk:~# ipsec status
Routed Connections:
sitea-to-siteb{1}:  ROUTED, TUNNEL
sitea-to-siteb{1}:   10.10.10.0/24 === 10.10.20.0/24
Security Associations (0 up, 0 connecting):
  none


root@adk:~# ipsec statusall
Status of IKE charon daemon (strongSwan 5.1.2, Linux 3.19.0-58-generic, x86_64):
  uptime: 24 minutes, since Oct 16 23:32:52 2016
  malloc: sbrk 1486848, mmap 0, used 320880, free 1165968
  worker threads: 11 of 16 idle, 5/0/0/0 working, job queue: 0/0/0/0, scheduled: 0
  loaded plugins: charon test-vectors aes rc2 sha1 sha2 md4 md5 rdrand random nonce x509 revocation constraints pkcs1 pkcs7 pkcs8 pkcs12 pem openssl xcbc cmac hmac ctr ccm gcm attr kernel-netlink resolve socket-default stroke updown eap-identity addrblock
Listening IP addresses:
  10.10.40.134
  10.10.10.137
Connections:
sitea-to-siteb:  10.10.40.134...10.10.40.135  IKEv1
sitea-to-siteb:   local:  [10.10.40.134] uses pre-shared key authentication
sitea-to-siteb:   remote: [10.10.40.135] uses pre-shared key authentication
sitea-to-siteb:   child:  10.10.10.0/24 === 10.10.20.0/24 TUNNEL
Routed Connections:
sitea-to-siteb{1}:  ROUTED, TUNNEL
sitea-to-siteb{1}:   10.10.10.0/24 === 10.10.20.0/24
Security Associations (0 up, 0 connecting):
  none

```

#3. Kết quả

- Tiến hành bắt gói tin trên máy trung gian khi 2 máy server "ping" nhau.

![](http://image.prntscr.com/image/f4f990af60c14326ad879f87f46e6ab6.png)

Các gói tin ISAKMP là các gói tin trao đổi khóa giữa 2 server.

Các gói tin ESP là các gói tin icmp đã được mã hóa khi đi trên đường truyền. 

#4. Tài liệu tham khảo.
- https://www.gypthecat.com/ipsec-vpn-host-to-host-on-ubuntu-14-04-with-strongswan
- https://wiki.strongswan.org/projects/strongswan/wiki/IpsecConf
