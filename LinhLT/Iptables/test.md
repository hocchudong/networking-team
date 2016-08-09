Sử dụng IPTables làm Firewall cho hệ thống mạng. Yêu cầu:
1. Dựng một máy chủ Linux, cài đặt IPTables làm FW cho hệ thống bao gồm: 
  - Một zone DMZ: gồm 1 máy chủ Web
  - Một zone Private: gồm các máy trạm
2. Trên FW cấu hình như sau:
  - NAT port 80 cho phép truy cập vào WebServer, mọi truy cập khác vào webserver từ Internet đều bị chặn
  - Chặn mọi kết nối từ ngoài vào zone Private
  - Cho phép một máy trong dải Private quản trị được WebServer
  - CHo phép các kết nối từ Private ra 


#1. Mô hình
![](http://image.prntscr.com/image/9fe6f0f152644db48cc7fded8c32edd9.png)

#2. Thực hiện
##2.1 Bật tính năng ip forward: Sửa file `/etc/sysctl.conf`

```sh
net.ipv4.ip_forward = 1
```
- Chạy lệnh `sysctl -p /etc/sysctl.conf`
#2. Cấu hình iptables

```sh
  iptables -t nat -I PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 10.10.10.150
  iptables -t nat -I POSTROUTING -o eth1 -p tcp --dport 80 -j SNAT --to-source 10.10.10.128
  iptables -t nat -I POSTROUTING -s 10.10.20.130 -p tcp -d 10.10.10.150 --dport 22 -j SNAT --to-source 10.10.10.128

  iptables -A FORWARD -i eth0 -o eth1 -p tcp --dport 80 -d 10.10.10.150 -j ACCEPT
  iptables -A FORWARD -s 10.10.20.130 -i eth2 -o eth1 -d 10.10.10.150 -p tcp --dport 22 -j ACCEPT
  iptables -A FORWARD -i eth0 -o eth1 -d 10.10.10.150 -j DROP

  iptables -t nat -A POSTROUTING -s 10.10.20.0/24 -o eth0 -j SNAT --to-source 172.16.69.128
```
  

