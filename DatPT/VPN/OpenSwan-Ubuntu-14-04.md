#Bài lab triển khiển OpenSwan VPN trên Ubuntu server 14.04.

**Mục Lục**

[I. Mô hình.] (#mohinh)

[II. Thực hiện.] (#thuchien)

[III. Kiểm thử.] (#kiemthu)

[IV. Lưu ý.] (#luuy)

****

- OpenSwan là một VPN dựa trên giao thức IPSEC chuẩn RFC2401 . IPSEC hoạt động nhanh , và được nhân kernel-level support. Khi 
đã kết nối vào mạng thì máy tính đó được xem như một máy con trong mạng . Đa số các giải pháp VPN dựa trên giao thức này đều 
yêu cầu phần cứng trên máy trạm cần thực hiện VPN.

<a name="mohinh"></a>
##I. Mô hình.

![scr5](http://i.imgur.com/hYD7YFJ.png)

- Mô hình triển khai bao gồm 2 máy chủ Ubuntu server 14.04 cài đặt OpenSwan , site A có địa chỉ IP public là 172.16.1.34 và 
địa chỉ private là 10.10.10.10 ; Site B có địa chỉ IP public là 172.16.1.135 và địa chỉ Ip private là 10.10.20.10, và 2 máy trạm 
bên trong LAN dùng để test.

<a name="thuchien"></a>
##II. Thực hiện.

```sh
Lưu ý : Bài lab thực hiện tất cả dưới quyền root.
```

- Đầu tiên chúng ta cần cài đặt OpenSwan trên Ubuntu server :

```sh
apt-get install openswan
```

- Sau đó chúng ta vô hiệu hóa chuyển hướng VPN nếu có, trên các site thực hiện :

```sh
for vpn in /proc/sys/net/ipv4/conf/*;
do echo 0 > $vpn/accept_redirects;
echo 0 > $vpn/send_redirects;
done
```

- Sau đó chúng ta thay đổi các tham số chuyển tiếp IP và vô hiệu hóa trang chuyển hướng vĩnh viễn.

- dùng trình soạn thảo `vi` để sửa file `/etc/sysctl.conf` , tìm và bỏ comment các dòng sau :

```sh
net.ipv4.ip_forward = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
```

- reload `/etc/sysctl.conf`:

```sh
sysctl -p
```

- Bước tiếp theo chúng ta cần thiết lập các rules của Iptables :

```sh
iptables -A INPUT -p udp --dport 500 -j ACCEPT
iptables -A INPUT -p tcp --dport 4500 -j ACCEPT
iptables -A INPUT -p udp --dport 4500 -j ACCEPT
```

- Tạo rules để NAT :

```sh
iptables -t nat -A POSTROUTING -s site-A-private-subnet -d site-B-private-subnet -j SNAT --to site-A-Public-IP
```

- Cấu hình IPSEC.

- dùng trình soạn thảo `vi` để chỉnh sửa file `/etc/ipsec.conf` :

```sh
vi /etc/ipsec.conf
```

- Chỉnh sửa lại file cấu hình như sau :

```sh
## general configuration parameters ##
 
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
        leftsourceip=<siteA-private-IP>
        leftsubnet=<siteA-private-subnet>/netmask
        ## for direct routing ##
        leftsubnets=<siteA-public-IP>/netmask
        leftnexthop=%defaultroute
        right=<siteB-public-IP>
        rightsubnet=<siteB-private-subnet>/netmask
```

- Tạo hình pre=share key :

```sh
vi /etc/ipsec.secrets
```

- thêm dòng sau :

```sh
172.16.1.134  172.16.1.135:  PSK  "123456a@"
```

- Trong đó :
 <ul>
  <li>172.16.1.134 : là địa chỉ IP public của site A.</li>
  <li>172.16.1.135 : là địa chỉ IP public của site B.</li>
  <li>123456a@ : key.</li>
 </ul>

- Restart lại dịch vụ:

```sh
/etc/init.d/ipsec restart
```

- Kiểm tra trạng thái hoạt động:

```sh
service ipsec status
```

![scr4](http://i.imgur.com/g5AgOwl.png)

<a name="kiemthu"></a>
##III. Kiểm thử kết quả.

- Ở đây mình sẽ dùng 2 máy trạm windows 7 , máy ở site A có địa chỉ IP là 10.10.10.12 và máy trạm ở site B có địa chỉ IP là 
10.10.20.12. Mình sẽ thực hiện ping 2 máy này với nhau :

![scr11](http://i.imgur.com/JltKzfd.png)

- Sau đó bật phần mềm `Wireshark` lên và chặn bắt gói tin trên đường truyền Internet ở đây là Card VMnet 8.

![scr6](http://i.imgur.com/eZaKIO7.png)

- Ở đây chúng ta có thể thấy các gói tin khi truyền giữa 2 site đều đã được mã hóa ở mức độ an toàn.

- Sau đó chúng ta thực hiện bắt gói tin trên Card VMnet 1, VMnet2 nơi mà các gói tin đã được giải mã xem kết quả thế nào:

![scr9](http://i.imgur.com/b4TkZsL.png)

![scr10](http://i.imgur.com/GPrRXm6.png)

- Như chúng ta có thể thấy trên hình trên thì tất cả các gói tin đều đã được giải mã và máy trạm có thể đọc được để trao đổi 
thông tin qua lại với nhau.

<a name="luuy"></a>
##IV. Những lưu ý khi thực hiện bài lab.

- Trước khi kiểm thử kết quả chúng ta nên reset lại tất cả các máy sau đó mới thực hiện kiểm thử, nếu không sẽ gặp tình trạng 
gói tin truyền trên đường truyền Internet sẽ không được mã hóa.

#NGUỒN:

- https://github.com/xelerance/Openswan
- http://giaiphap365.com/thu-thuat/thu-thuat-may-tinh/huong-dan-trien-khai-vpn-openswan-tu-a-z.html
- https://raymii.org/s/tutorials/IPSEC_L2TP_vpn_with_Ubuntu_14.04.html
- http://tylerbaird.com/offtopic/ubuntu-1404-vpn-configuration
- http://ryotamono.com/2015/03/Install%20L2TP%20Server%20on%20Ubuntu/
- https://trick77.com/strongswan-5-vpn-ubuntu-14-04-lts-psk-xauth/
- http://xmodulo.com/create-site-to-site-ipsec-vpn-tunnel-openswan-linux.html
- http://www.slashroot.in/linux-ipsec-site-site-vpnvirtual-private-network-configuration-using-openswan