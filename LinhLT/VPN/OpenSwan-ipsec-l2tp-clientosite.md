Setting Up an IPSec L2TP VPN server on Ubuntu

#1. Mô hình
![](http://i.imgur.com/PU5mwgZ.jpg)

Mục đích:
Client (chạy win7) có thể truy cập vào vpn server, để có thể nói chuyện được với mạng Lanprivate, một cách bảo mật trên đường truyền internet.

#2. Thực hiện
#2.1 Cấu hình ipsec
```sh
sudo apt-get install openswan -y
```

```sh
sudo vi /etc/ipsec.conf
```
- Thay **YOUR.SERVER.IP.ADDRESS** bằng địa chỉ ip public của bạn.

```sh
version 2.0
config setup
    nat_traversal=yes
    virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12
    oe=off
    protostack=netkey

conn L2TP-PSK-NAT
    rightsubnet=vhost:%priv
    also=L2TP-PSK-noNAT

conn L2TP-PSK-noNAT
    authby=secret
    pfs=no
    auto=add
    keyingtries=3
    rekey=no
    ikelifetime=8h
    keylife=1h
    type=transport
    left=YOUR.SERVER.IP.ADDRESS
    leftprotoport=17/1701
    right=%any
    rightprotoport=17/%any
```
##2.2 Cấu hình ipsec.secrets
```sh
vi /etc/ipsec.secrets
```

Thay thế **YOUR.SERVER.IP.ADDRESS** bằng ip của bạn và **YourSharedSecret** bằng khóa PSK của bạn.
```
YOUR.SERVER.IP.ADDRESS   %any:  PSK "YourSharedSecret"
```

##2.3 không cho phép chuyển hướng.

```sh
for each in /proc/sys/net/ipv4/conf/*
do
    echo 0 > $each/accept_redirects
    echo 0 > $each/send_redirects
done
```

- Restart openswan
```sh
service ipsec restart
```

##2.4 Cấu hình xl2tpd
```sh
apt-get install xl2tpd -y
```

```sh
vi /etc/xl2tpd/xl2tpd.conf
```

```sh
[global]
ipsec saref = no

[lns default]
ip range = 172.22.1.2-172.22.1.99
local ip = 172.22.1.1
refuse chap = yes
refuse pap = yes
require authentication = yes
ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
```

##2.5 Cấu hình PPP
```sh
apt-get install ppp -y
```

```sh
vi /etc/ppp/options.xl2tpd
```

```sh
require-mschap-v2
ms-dns 8.8.8.8
ms-dns 8.8.4.4
asyncmap 0
auth
crtscts
lock
hide-password
modem
debug
name l2tpd
proxyarp
lcp-echo-interval 30
lcp-echo-failure 4
```

```sh
vi /etc/ppp/chap-secrets
```

```sh
# user         server      password        ip
student        l2tpd       P@ssw0rd        *
```

```sh
service xl2tpd restart
```



#3. Cấu hình trên client win7
- Thực hiện theo các bước sau

![](https://samsclass.info/ipv6/proj/VPN-26.png)

![](https://samsclass.info/ipv6/proj/VPN-27.png)

![](https://samsclass.info/ipv6/proj/VPN-28.png)

![](https://samsclass.info/ipv6/proj/VPN-29.png)

![](https://samsclass.info/ipv6/proj/VPN-30.png)

![](https://samsclass.info/ipv6/proj/VPN-31.png)


#4. Kết quả.

- Client tiến hành kết nối

![](http://image.prntscr.com/image/723ba9b6d7394c60ba7e8faeab63220b.png)

- Khi Client kết nối thành công, địa chỉ ip của client nhận được là:

![](http://image.prntscr.com/image/b11c080182ce46649d475a61e79a4b44.png)

- Ping máy trong mạn Lan private

![](http://image.prntscr.com/image/8f6243229f4842c28804c90ca621fbf0.png)

- Tiến hành bắt gói tin

![](http://image.prntscr.com/image/50e7df9da7f4433f8300bf6b956ae581.png)

#5. Tài liệu tham khảo
https://samsclass.info/ipv6/proj/proj-L5-VPN-Server.html