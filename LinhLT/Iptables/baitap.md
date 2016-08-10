#MỤC LỤC
- [1. Yêu cầu:](#yeucau)
- [2. Mô hình](#mohinh)
- [3. Thực hiện](#thuchien)
  - [3.1 Bật tính năng ip forward:](#ipforward)
  - [3.2 Cấu hình iptables](#cauhinh)
- [4. Kết quả](#ketqua)


<a name="yeucau"></a>
#1. Yêu cầu:

Sử dụng IPTables làm Firewall cho hệ thống mạng. Yêu cầu:

1. Dựng một máy chủ Linux, cài đặt IPTables làm FW cho hệ thống bao gồm:
  - Một zone DMZ: gồm 1 máy chủ Web
  - Một zone Private: gồm các máy trạm

2. Trên FW cấu hình như sau:
  - NAT port 80 cho phép truy cập vào WebServer, mọi truy cập khác vào webserver từ Internet đều bị chặn
  - Chặn mọi kết nối từ ngoài vào zone Private
  - Cho phép một máy trong dải Private quản trị được WebServer
  - CHo phép các kết nối từ Private ra

<a name="mohinh"></a>
#2. Mô hình
![](http://image.prntscr.com/image/9fe6f0f152644db48cc7fded8c32edd9.png)

- Các thông số: Chú ý, các máy trong vùng mạng LAN private đặt gateway là địa chỉ firewall.
- Firewall: Chạy hệ điều hành Ubuntu14.04sv, sử dụng iptables phiên bản, có 3 card mạng nối với 3 vùng mạng khác nhau:
```sh
card eth0 có địa chỉ ip là 172.16.69.128, là địa chỉ public, kết nối với nhà cung cấp dịch vụ INTERNET
card eth1 có địa chỉ ip private là 10.10.10.128, kết nối với vùng mạng DMZ (Webserver)
card eth2 có địa chỉ ip private là 10.10.20.128, kết nối với vùng mạng LAN private.
```
- Webserver: Chạy hệ điều hành Ubuntu14.04sv, sử dụng apache2 làm webserver, có 1 card mạng
```sh
card eth0 có địa chỉ ip private là 10.10.10.150, kết nối với cổng eth1 của firewall
```
- Các máy client chạy hề điều hành Ubuntu14.04sv, trong đó
  - Máy tính **PC0**:
  ```sh
  card eth0 có địa chỉ ip 10.10.20.130 nối với cổng eth2 của firewall, PC0 có quyền truy cập ssh đến webserver
  ```
  - Các máy tính **CopyPC0**, **CopyCopyPC0** có card eth0 kết nối với cổng eth2 của firewall

<a name="thuchien"></a>
#3. Thực hiện
<a name="ipforward"></a>
##3.1 Bật tính năng ip forward:
- Tính năng ip fordward cần kích hoạt để iptables có thể chuyển tiếp được gói tin sang các máy khác.

- Ta cần sửa file `/etc/sysctl.conf`

```sh
net.ipv4.ip_forward = 1
```
- Chạy lệnh `sysctl -p /etc/sysctl.conf` để kiểm tra cài đặt.

<a name="cauhinh"></a>
##3.2 Cấu hình iptables

```sh
  iptables -t nat -I PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 10.10.10.150
  iptables -t nat -I POSTROUTING -o eth1 -p tcp --dport 80 -j SNAT --to-source 10.10.10.128
  iptables -A FORWARD -i eth0 -o eth1 -p tcp --dport 80 -d 10.10.10.150 -j ACCEPT
  iptables -t nat -I POSTROUTING -s 10.10.20.130 -p tcp -d 10.10.10.150 --dport 22 -j SNAT --to-source 10.10.10.128
  iptables -A FORWARD -s 10.10.20.130 -i eth2 -o eth1 -d 10.10.10.150 -p tcp --dport 22 -j ACCEPT
  iptables -A FORWARD -i eth0 -o eth1 -d 10.10.10.150 -j DROP
  iptables -t nat -A POSTROUTING -s 10.10.20.0/24 -o eth0 -j SNAT --to-source 172.16.69.128
  iptables -A INPUT -i eth0 -j DROP
```

##3.3 Giải thích các dòng lệnh:
###3.3.1 Cho phép truy cập vào WebServer, mọi truy cập khác vào webserver từ Internet đều bị chặn

Để thực hiện chức năng này, ta cần các lệnh cấu hình sau.
- Dòng 1:
```sh
iptables -t nat -I PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 10.10.10.150
```
Có tác dụng ở bảng **NAT**, chain **PREROUTING**, dùng để thay đổi địa chỉ đích sang `10.10.10.150` của các gói tin đi vào từ interface eth0 (interface kết nối đến mạng internet), và có port đích là 80 (truy cập dịch vụ http)

**=> Giải thích: Bởi vì webserver nằm trong vùng mạng DMZ, có địa chỉ private là 10.10.10.150, nên máy trên internet, muốn truy cập vào webserver thì phải thay đổi từ địa chỉ public của firewall (172.16.69.128) sang địa chỉ 10.10.10.150**

- Dòng 2:
```sh
iptables -t nat -I POSTROUTING -o eth1 -p tcp --dport 80 -j SNAT --to-source 10.10.10.128
```
Có tác dụng ở bảng **NAT**, chain **POSTROUTING**, dùng để thay đổi địa chỉ nguồn sang `10.10.10.128` (địa chỉ cùng dãy mạng với webserver), của các gói tin đi ra cổng eth1 (nối với vùng DMZ), các gói tin tcp, port đích là 80. =>Để có thể truy cập được webserver.

**=> Giải thích: Bởi vì webserver nằm trong vùng DMZ và dùng dải địa chỉ private, do đó chỉ có những máy nằm trong dải private này mới có thể truy cập được webserver. Vì vậy, chúng ta cần thay đổi địa chỉ nguồn của các máy trên internet sang địa chỉ của firewall, thì mới có thể truy cập được webserver.**
- Dòng 3:
```sh
iptables -A FORWARD -i eth0 -o eth1 -p tcp --dport 80 -d 10.10.10.150 -j ACCEPT
```
Có tác dụng ở bảng **FILTER**, chain **FORWARD**, cho phép chuyển các gói tin tcp có port đích là 80 từ cổng eth0 sang cổng eth1

**=> Giải thích: IPTables ở đây có nhiệm vụ forward các gói tin sang webserver, chứ nó không xử lý trực tiếp các yêu cầu truy cập http của người dùng trên internet**

- Dòng 6:
```sh
iptables -A FORWARD -i eth0 -o eth1 -d 10.10.10.150 -j DROP
```
Có tác dụng ở bảng **FILTER**, chain **FORWARD**, dùng để ngăn chặn các gói tin đi vào từ eth0, đi ra eth1 và có địa chỉ đích là 10.10.10.150 (web server).

**=> Giải thích: Dùng để ngăn chặn các truy cập trái phép (ngoại trừ truy cập dịch vụ http)từ mạng INTERNET vào webserver**

###3.3.2 Cho phép một máy trong dải Private quản trị được WebServer
Để thực hiện chức năng này, ta cần các lệnh cấu hình sau.

- Dòng 4:
```sh
iptables -t nat -I POSTROUTING -s 10.10.20.130 -p tcp -d 10.10.10.150 --dport 22 -j SNAT --to-source 10.10.10.128
```
Có tác dụng ở bảng **NAT**, chain **POSTROUTING**, dùng để thay đổi địa chỉ nguồn sang `10.10.10.128` của các gói tin xuất phát từ máy `10.10.20.130`(pc1), địa chỉ đích của gói tin là `10.10.10.150` và port đích là 22.

**=> Giải thích: Muốn 1 máy trong dải mạng LAN private có thể ssh được webserver thì máy đó phải có cùng dải mạng với webserver. Vì vậy, chúng ta cần phải thay đổi địa chỉ nguồn của máy `10.10.20.130` sang địa chỉ ip của firewall**

- Dòng 5
```sh
iptables -A FORWARD -s 10.10.20.130 -i eth2 -o eth1 -d 10.10.10.150 -p tcp --dport 22 -j ACCEPT
```
Có tác dụng ở bảng **FILTER**, chain **FORWARD**, dùng để cho phép chuyển tiếp các gói tin có địa chỉ nguồn là `10.10.20.130` đi vào từ cổng eth2 (mạng LAN private), đi ra cổng eth1 (vùng DMZ), có địa chỉ đích là `10.10.10.150` và port đích là 22.

**=> Giải thích: IPtables có nhiệm vụ fordward các gói tin ssh sang webserver.**


###3.3.3 Cho phép các kết nối từ Private ra
Để thực hiện chức năng này, ta cần các lệnh cấu hình sau.

- Dòng 7:
```sh
iptables -t nat -A POSTROUTING -s 10.10.20.0/24 -o eth0 -j SNAT --to-source 172.16.69.128
```
Có tác dụng ở bảng **NAT**, chain **POSTROUTING**, dùng để thay đổi địa chỉ nguồn từ vùng vùng mạng `10.10.20.0/24` (LAN private) đi ra cổng eth0, sang địa chỉ `172.16.69.128`.

**=> Giải thích: Máy trong mạng LAN private muốn truy cập được internet thì cần phải thay đổi địa chỉ nguồn của các máy này sang địa chỉ ip public của firewall**


###3.3.4 Chặn mọi kết nối từ ngoài vào zone Private
- Dòng 8:
```sh
iptables -A INPUT -i eth0 -j DROP
```
Có tác dụng ở bảng **FILTER**, chain **INPUT**, dùng để chặn mọi kết nối từ bên ngoài vào máy firewall.

**=> Giải thích: Bởi vì zone private sử dụng ip public của firewall, cho nên ở đây, tôi đã chặn mọi kết nối từ internet vào firewall, ngoại trừ các ngoại lệ ở trên.**

<a name="ketqua"></a>
#4. Kết quả

- Một client trên internet có địa chỉ ip public là 172.16.69.150, tiến hành truy cập webserver

![](http://image.prntscr.com/image/507cd7073c914bc6bef403acb7f75d32.png)

- Trên máy PC0 thuộc dải mạng LAN private có địa chỉ ip 10.10.20.130, có quyền truy cập ssh đến webserver
![](http://image.prntscr.com/image/baa3542a0b5644fea50fa96ade1150fa.png)

- Trên máy COPYPC0 có địa chỉ 10.10.20.131 thử tiến hành truy cập internet (Truy cập máy 172.16.69.50)

![](http://image.prntscr.com/image/011847fd5617476ea0962f37d39fe41b.png)

- Chặn mọi kết nối, ngoại trừ kết hối http đến firewall, thử ping từ một máy trên internet 172.16.69.150 đến địa chỉ firewall, kết quả là thất bại

![](http://image.prntscr.com/image/fe0c7c9d46ee48f3aafa411423f1c4a7.png)
