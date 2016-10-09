#Bài lab StrongSwan VPN site-to-site Ubuntu server 14.04.

**Mục Lục**

[I. Mô hình.] (#mohinh)

[II. Thực hiện.] (#thuchien)

[III. Kiểm thử.] (#kiemthu)

[IV. Lưu ý.] (#luuy)

****

<a name="mohinh"></a>
##I. Mô hình.

![scr5](http://i.imgur.com/SW0OR8X.png)

- Ở đây mình sử dụng mô hình bao gồm 2 máy chủ Ubuntu server 14.04 cài đặt StrongSwan có địa chỉ IP public và private lần lượt là site A : 
`172.16.1.134` và `10.10.10.10` ; Site B `172.16.1.135` và `10.10.20.10` 2 máy trạm để kiểm thử kết quả có địa chỉ lần lượt là 
Host 1 `10.10.10.12` và Host 2 `10.10.20.12`

<a name="thuchien"></a>
##II. Thưc hiện.

```sh
Lưu ý : Bài lab được thực hiện tất cả dưới quyền ROOT.
```

**Tại site A**

- Đầu tiên chúng ta cài đặt gói StrongSwan cho máy chủ Ubuntu server :

```sh
apt-get install strongswan
```

- Thay đổi các tham số chuyển hướng IP và vô hiệu hóa chuyển hướng trang :

- Tìm các dòng sau trong file `/etc/sysctl.conf` và bỏ dấu comment(#) đằng trước nó :

```sh
net.ipv4.ip_forward = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
```

- Thiết lập firewall :

```sh
iptables -A INPUT -p udp --dport 500 -j ACCEPT
iptables -A INPUT -p tcp --dport 4500 -j ACCEPT
iptables -A INPUT -p udp --dport 4500 -j ACCEPT
```

- Tại rule dành cho NAT :

```sh
iptables -t nat -A POSTROUTING -s site-A-private-subnet -d site-B-private-subnet -j SNAT --to site-A-Public-IP
```

- Cấu hình `IPSEC` tại file `/etc/ipsec.conf`

```sh
vi /etc/ipsec.conf
```

- Chỉnh sửa file cấu hình như sau :

```sh
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
    right=172.16.1.134
    left=172.16.1.135
    leftauth=psk
    rightauth=psk
    rightsubnet=10.10.10.0/24
    leftsubnet=10.10.20.0/24
    aggressive=no
    dpdtimeout=120s
    type=tunnel
```

- Tạo Pre-share key :

```sh
vi /etc/ipsec.secrets
```

- Thêm vào dòng sau :

```sh
172.16.1.134  172.16.1.135:  PSK  "123456"
```

- Trong đó :
 <ul>
  <li>172.16.1.134 : là địa chỉ IP public của site A.</li>
  <li>172.16.1.135 : là địa chỉ IP public của site B.</li>
  <li>123456 : key.</li>
 </ul>

- Restart lại IPSEC :

```sh
ipsec restart
```

**Tại site B**

- Đầu tiên chúng ta cài đặt gói StrongSwan cho máy chủ Ubuntu server :

```sh
apt-get install strongswan
```

- Thay đổi các tham số chuyển hướng IP và vô hiệu hóa chuyển hướng trang :

- Tìm các dòng sau trong file `/etc/sysctl.conf` và bỏ dấu comment(#) đằng trước nó :

```sh
net.ipv4.ip_forward = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
```

- Thiết lập firewall :

```sh
iptables -A INPUT -p udp --dport 500 -j ACCEPT
iptables -A INPUT -p tcp --dport 4500 -j ACCEPT
iptables -A INPUT -p udp --dport 4500 -j ACCEPT
```

- Tại rule dành cho NAT :

```sh
iptables -t nat -A POSTROUTING -s site-B-private-subnet -d site-A-private-subnet -j SNAT --to site-B-Public-IP
```

- Cấu hình `IPSEC` tại file `/etc/ipsec.conf`

```sh
vi /etc/ipsec.conf
```

- Chỉnh sửa file cấu hình như sau :

```sh
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
    right=172.16.1.135
    left=172.16.1.134
    leftauth=psk
    rightauth=psk
    rightsubnet=10.10.20.0/24
    leftsubnet=10.10.10.0/24
    aggressive=no
    dpdtimeout=120s
    type=tunnel
```

- Tạo Pre-share key :

```sh
vi /etc/ipsec.secrets
```

- Thêm vào dòng sau :

```sh
172.16.1.135  172.16.1.134:  PSK  "123456"
```

- Trong đó :
 <ul>
  <li>172.16.1.134 : là địa chỉ IP public của site A.</li>
  <li>172.16.1.135 : là địa chỉ IP public của site B.</li>
  <li>123456 : key.</li>
 </ul>

- Restart lại IPSEC :

```sh
ipsec restart
```

- Sau đó tiến hành Ping kiểm thử từ site A sang site B:

```sh
ping -s 4048 10.10.20.10
```

- Kiểm tra lại trạng thái hoạt động của hệ thống :

```sh
ipsec status
```

- Kết quả :

![scr4](http://i.imgur.com/priC67F.png)

<a name="kiemthu"></a>
##III. Kiểm thử.

- Ở đây mình dùng 2 máy trạm tại 2 site A và B. Máy trạm ở site A có địa chỉ IP là `10.10.10.12` và máy trạm ở site B có địa 
chỉ IP là `10.10.20.12` . Chúng ta sẽ tiến hành Ping giữa 2 máy trạm với nhau và dùng `Wireshark` để tiến hành bắt gói tin và 
kiểm tra gói tin đó.
- Đầu tiên chúng ta thực hiện PING giữa các máy trạm với nhau :

![scr3](http://i.imgur.com/lU8ss6O.png)

- Sau đó dùng `Wireshark` tiến hành bắt gói tin khi chúng được truyền trên đường truyền Internet, cụ thể ở đây là card VMnet8 :

![scr1](http://i.imgur.com/6eSEZry.png)

- Như chúng trong hình chúng ta có thể thấy được các gói tin khi được vận chuyển trên đường truyền Internet thì đều đã được mã 
hóa và chúng ta không thể đọc được chúng => an toàn.

- Sau đó chúng ta thực hiện bắt gói tin khi chúng đã được giải mã tại VPN server, cụ thể ở đây là card VMnet1 và VMnet2 :

![scr2](http://i.imgur.com/eVd7vx0.png)

- Như trong hình chúng ta có thể thấy được gói tin đã được giải mã và các máy trạm khi yêu cầu đến VPN server có thể lấy được 
thông tin cần thiết và có thể trao đổi thông tin với nhau.

<a name="luuy"></a>
##IV. Lưu ý khi thực hiện bài lab.

- Trước khi kiểm thử kết quả chúng ta nên reset lại tất cả các máy sau đó mới thực hiện kiểm thử, nếu không sẽ gặp tình trạng 
gói tin truyền trên đường truyền Internet sẽ không được mã hóa.

#Nguồn:

- http://serverfault.com/questions/386000/ipsec-vpn-site-to-site-how-should-i-configure-the-ipsec-conf-files-on-both-site
- https://www.gypthecat.com/ipsec-vpn-host-to-host-on-ubuntu-14-04-with-strongswan
- https://console.ng.bluemix.net/docs/services/vpn/onpremises_gateway.html
- http://www.brocade.com/content/html/en/vrouter5600/42r1/vrouter-42r1-ipsecvnp/GUID-56D8C2B0-1498-4D5C-9FC4-2FD62AE06B7F.html
- http://serverfault.com/questions/570059/strongswan-vpn-established-but-no-packets-routed