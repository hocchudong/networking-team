#OpenSwan site to site.

#1. Mô hình.

![](http://i.imgur.com/tJZX48d.jpg)

- site A: 
	- Địa chỉ ip public: 10.10.40.129/24 
	- Địa chỉ ip mạng lan private: 10.10.10.133/24 

- site B:
	- Địa chỉ ip public: 10.10.40.130/24
	- Địa chỉ ip mạng lan private: 10.10.20.135/24

- Mục đích:
	- Hai mạng Lan private ở 2 site có thể nói chuyện được với nhau trên đường truyền Internet một cách bảo mật, thông quan OpenSwan được cấu hình ở 2 server vpn.
	- Ngăn chặn hành động "nghe lén" mà hacker bắt các gói tin ở giữa đường truyền.

#2. Thực hiện
##2.1 Cài đặt các bước ban đầu.

Các bước sau, các bạn thực hiện lần lượt trên cả 2 site A và B.

- Cài đặt OpenSwan trên Ubuntu server:
```sh
apt-get install openswan
```

- Vô hiệu hóa chuyển hướng VPN nếu có, trên các site thực hiện :
```sh
for vpn in /proc/sys/net/ipv4/conf/*;
do echo 0 > $vpn/accept_redirects;
echo 0 > $vpn/send_redirects;
done
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

```sh
config setup
        plutodebug=all
        plutostderrlog=/var/log/pluto.log
        protostack=netkey
        nat_traversal=yes
        virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12
        oe=off

## connection definition in Debian ##
conn demo-connection-debian
        authby=secret
        auto=start
        ## phase 1 ##
        keyexchange=ike
        ## phase 2 ##
        esp=3des-md5
        pfs=yes
        type=tunnel
        left=<siteA-public-IP>
        leftsourceip=<siteA-public-IP>
        leftsubnet=<siteA-private-subnet>/netmask
        ## for direct routing ##
        leftsubnets=<siteA-public-IP>/netmask
        leftnexthop=%defaultroute
        right=<siteB-public-IP>
        rightsubnet=<siteB-private-subnet>/netmask
```

|Lệnh|Ý nghĩa|
|:---:|:---:|
|protostack=netkey|Trên Linux, có 2 IPSec stacks, đó là NETKEY và KLIPS. NETKEY mặc định có sẵn trong Linux kernel còn KLIPS thì không. Do đó, tôi chọn là NETKEY trong trường hợp này.|
|nat_traversal=yes| Cho phép các gói tin IPSec đi qua các thiết bị NAT.
| virtual_private|Add các dải mảng private không được sử dụng. (The best method is to add all private subnet except those ranges used by the server).|
|oe=off| disable opportunistic encryption in Debian|
|conn | Đặt tên cho connection, dùng để phân biệt các tunnels|
|authby| Cách thức các server thực hiện xác thực. Sử dụng `secret` với cách shared secret hoặc `rsasig` với cách RSASIG. Mình có nói phần này ở dưới.|
|type| Kiểu kết nối. Với `tunnel` thì chấp nhận: host-to-host, host-to-subnet, hoặc subnet-to-subnet. Với `transport` chấp nhận host-to-host.|
|keyexchange=ike| Tiến hành xác thực khóa bằng giao thức ike|
|esp=3des-md5| Phương thức mã hóa gói tin|
|left| Địa chỉ ip public của server đang cấu hình|
|leftsourceip| Địa chỉ ip public của server đang cấu hình
|leftsubnet| Đại chỉ mạng lan private trên đang cấu hình|.
|right| Địa chỉ ip public của server cần kết nối (server B)|
|rightsubnet| Địa chỉ ip mạng lan private trên server cần kết nối (server B)


- Với mô hình như trên thì cấu hình ở ipsec site A như sau:
```sh
config setup
        plutodebug=all
        plutostderrlog=/var/log/pluto.log
        protostack=netkey
        nat_traversal=yes
        virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12
        oe=off
conn vpn
        authby=secret
        auto=start
        ## phase 1 ##
        keyexchange=ike
        ## phase 2 ##
        esp=3des-md5
        pfs=yes
        type=tunnel
        left=10.10.40.129
        leftsourceip=10.10.10.133
        leftsubnet=10.10.10.0/24
        ## for direct routing ##
        leftsubnets=10.10.40.0/24
        leftnexthop=%defaultroute
        right=10.10.40.130
        rightsubnet=10.10.20.0/24
```

- Cầu hình ipsec ở site B:
```sh
config setup
        plutodebug=all
        plutostderrlog=/var/log/pluto.log
        protostack=netkey
        nat_traversal=yes
        virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12
        oe=off
conn vpn
        authby=secret
        auto=start
        ## phase 1 ##
        keyexchange=ike
        ## phase 2 ##
        esp=3des-md5
        pfs=yes
        type=tunnel
        left=10.10.40.130
        leftsourceip=10.10.20.135
        leftsubnet=10.10.20.0/24
        ## for direct routing ##
        leftsubnets=10.10.40.0/24
        leftnexthop=%defaultroute
        right=10.10.40.129
        rightsubnet=10.10.10.0/24
```

##2.3 Cấu hình xác thực
OpenSwan ipsec cho phép t sử dụng 2 phương thức để xác thực các gói tin khi đi qua tunnel, đó là: **Shared Secret** hoặc **RSA key**.

Lưu ý là chúng ta chỉ chọn 1 trong 2 phương thức để xác thực.

###2.3.1 Pre-Share-Key
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
10.10.40.129    10.10.40.130 :  PSK  "123456a@"
```

- Tương tự, với site B.
```sh
10.10.40.130    10.10.40.129 :  PSK  "123456a@"
```

- Restart lại dịch vụ
```sh
service ipsec restart
```

###2.3.2 RSA key
- Phương thức xác thực thứ 2, sử dụng RSAIG.
- Chúng ta cần tạo rsa keys trên cả 2 server vpn.
- Để tạo rsa key cho vpn server, ta chạy lệnh sau: 
```sh
root@adk:~# ipsec newhostkey --output /etc/ipsec.secrets --bits 2048 --verbose --hostname <your VPN server hostname>
```
Trong đó, bạn cần tạo thay đổi **<your VPN server hostname>** bằng hostname của server bạn.

Lệnh trên sẽ tạo key có độ dài là 2048 bit

Chạy lệnh tạo key ở trên với server vpn còn lại.

- Chỉnh sửa file `ipsec.conf`, sửa và thêm các thông số sau.
```sh
authby=rsasig
leftrsasigkey=keypublic của chính server.
rightrsasigkey=keypublic của server bên kia.
```
- Trong đó:
	- **leftrsasigkey:** là key rsa public trên chính vpn server này.
	- **rightrsasigkey:** là key rsa trên vpn server bên kia.

- Các cấu hình còn lại giữ nguyên giống như ở trên.
- Ví dụ ở trên site A, tôi có cấu hình như sau:
```sh
conn vpn
	authby=rsasig

	leftrsasigkey=0sAQOXleUvusHJRkzJOlNw6B1xbMBOTEZXeGkeRj48MOC/F4VtXgLD7DNlPmrPDHaA4TQ0B2agMIgR/uY+tXiaknwzRVR0L/3OVLlZklnOkToo27ofMB+COPbcPpNMXZgwPkmCeMdf8CuPJcZdqw20/fI7LJC83PPXwFJf7O7SH1hjBznFdFNh8EnKDDoCic4qEu9ECXGmBELHiHBS+yKGeOfAb9wPjagJD7N+qcjijyBfEms2yVqodbfq3yGrGzfvw1xOLTgLWSVKqLOuEj0HF4njMGBh6/GtLCVwNoTOpkLj+J9WyEvELjS/Z2hrUslERwJBK8186IYGmq8gqUjxGfRh

	rightrsasigkey=0sAQNXuoHPULTMOwzXX+CwiQSFq6OnxIkvUEa+6tkk9dtCONZnS7fYDtt+DxVgFShsUC2nOE4crRqrIyDBXCAWHutbTisdSROKS3pBhBRYC1jlxN6gg6Vz+2HvxgsXlatO4NdS9+e2DWH65mvuF9O+Ty6IAGaUZfHsmqvdbqeCn/0RApoYvJmSW6XQZymwq5X5gELG1/2l2NkEzbzdHBhUH/XcjaeVKSY1U8PVDAPHfdpIuT6L46CFvzBeMUyE/7J9/psy+ugIC72LY5HvgAxVtQiMe/h864UuB6cu2iPzZPDYPdgc8+69nGPDnvOnDk17Y5/tBfw4tyfKzoFxQal2dxbp

```

- Trên site B:
```sh
conn vpn
    authby=rsasig

    leftrsasigkey=0sAQNXuoHPULTMOwzXX+CwiQSFq6OnxIkvUEa+6tkk9dtCONZnS7fYDtt+DxVgFShsUC2nOE4crRqrIyDBXCAWHutbTisdSROKS3pBhBRYC1jlxN6gg6Vz+2HvxgsXlatO4NdS9+e2DWH65mvuF9O+Ty6IAGaUZfHsmqvdbqeCn/0RApoYvJmSW6XQZymwq5X5gELG1/2l2NkEzbzdHBhUH/XcjaeVKSY1U8PVDAPHfdpIuT6L46CFvzBeMUyE/7J9/psy+ugIC72LY5HvgAxVtQiMe/h864UuB6cu2iPzZPDYPdgc8+69nGPDnvOnDk17Y5/tBfw4tyfKzoFxQal2dxbp

    rightrsasigkey=0sAQOXleUvusHJRkzJOlNw6B1xbMBOTEZXeGkeRj48MOC/F4VtXgLD7DNlPmrPDHaA4TQ0B2agMIgR/uY+tXiaknwzRVR0L/3OVLlZklnOkToo27ofMB+COPbcPpNMXZgwPkmCeMdf8CuPJcZdqw20/fI7LJC83PPXwFJf7O7SH1hjBznFdFNh8EnKDDoCic4qEu9ECXGmBELHiHBS+yKGeOfAb9wPjagJD7N+qcjijyBfEms2yVqodbfq3yGrGzfvw1xOLTgLWSVKqLOuEj0HF4njMGBh6/GtLCVwNoTOpkLj+J9WyEvELjS/Z2hrUslERwJBK8186IYGmq8gqUjxGfRh

```


#3. Kết quả.
- Trạng thái hoạt động
```sh
root@adk:~# service ipsec status


IPsec running  - pluto pid: 6227
pluto pid 6227
2 tunnels up
some eroutes exist
```

Nếu bạn kiểm tra mà không có tunnels hoạt động, thì hãy kiểm tra lại bảng định tuyến. Khi tôi thực hiện bài lab, bảng định tuyến mà không có default gateway thì sẽ không thể tạo được tunnel.

- Tiến hành bắt gói tin trên máy trung gian khi 2 máy server "ping" nhau.

![](http://image.prntscr.com/image/ae9dad6286254b5aaa8ab5962051ca89.png)

Các gói tin ISAKMP là các gói tin trao đổi khóa giữa 2 server.

Các gói tin ESP là các gói tin icmp đã được mã hóa khi đi trên đường truyền. 

#4. Chú ý:
- Nếu là Direct routing thì các bạn không cần phải nat, ngược lại, các bạn phải nat trước khi đi ra internet.

- Câu lệnh dưới đây sẽ dùng iptables để thay đổi địa chỉ nguồn của gói tin trong mạng private trước khi được gửi ra internet.
```sh
root@adk:~# iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -j MASQUERADE
```

#5. Tài liệu tham khảo
- http://xmodulo.com/create-site-to-site-ipsec-vpn-tunnel-openswan-linux.html
- http://www.slashroot.in/linux-ipsec-site-site-vpnvirtual-private-network-configuration-using-openswan
 	