#NOTE
Một vài lưu ý mà tôi đã rút ra được trong quá trình tìm hiểu về iptables. :D

##1. IPtables xử lý các rule theo thứ tự từ trên xuống dưới.

Cụ thể là:
```sh
$ sudo iptables -L

Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:ssh
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:http
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:https
DROP       all  --  anywhere             anywhere
```
- Nếu server nhận được request trên port 22(ssh) hoặc port 80(http) hoặc port 443 https, thì server sẽ đồng ý các request này.

- Nếu các request không phải là giao thức tcp trên ssh hoặc http hoặc https thì sẽ bị DROP.

##2. Sự khác nhau giữa tùy chọn -A và -I.
- **-A, --append**: Tùy chọn `-A` sẽ thêm một rule mới vào cuối danh sách rule. (append)
- **-I, --insert chain [rulenum]**: Tùy chọn `-I` sẽ chèn thêm một rule mới, mình có thể chọn được vị trí mà nó sẽ được chèn vào trong danh sách rule, dựa vào thông số rulenum. Nếu `rulenum = 1` thì rule sẽ được chèn vào đầu danh sách rule. Và nếu mình không khai báo rulenum, thì mặc định `rulenum = 1`

##3.Persistence

Danh sách các rules của iptables sẽ được lưu trong memory. Và nếu bạn khởi động lại server thì các rules sẽ mất, do đó, bạn cần phải lưu chúng vào một file.

- Lưu các rules vào file `/etc/iptables/iptables.rules`
```sh
$ sudo iptables-save | sudo tee /etc/iptables/iptables.rules
```
- Restore lại các rule
```sh
$ sudo iptables-restore < /etc/iptables/iptables.rules
```

- Ở một vài hệ điều hành khác, bạn có thể sử dụng `systemd` hoặc một vài tool khác để add rules vào boot. Ở ubuntu, nó có tên là `iptables-persistent`.
```sh
$ sudo apt-get install -y iptables-persistent
```
- Khởi động dịch vụ
```sh
$ sudo service iptables-persistent start
```
- Sau khi installing, bạn sẽ thấy các file mới trong thư mục `/etc/iptables`
```sh
/etc/iptables/rules.v4 #ipv4
/etc/iptables/rules.v6 #ipv6
```

- Bạn có thể lưu các file rule bằng lệnh như ở trên
```sh
sudo iptables-save | sudo tee /etc/iptables/rules.v4
sudo ip6tables-save | sudo tee /etc/iptables/rules.v6
```
- Khởi chạy dịch vụ
```sh
$ sudo service iptables-persistent restart
```

###############
fail2ban: http://www.fail2ban.org/wiki/index.php/Main_Page

fwsnort: Application Layer IDS/IPS with iptables

http://cipherdyne.org/fwsnort/

 Or you can use the iptables recent module 

 http://ossec.github.io/downloads.html

 you can use something like fail2ban, which IIRC, has an Apache log checker built in.

 

To control or block http traffic, you can use :

apache module.
iptable
fail2ban as stated here by HopelessN0ob.

iptables -I FORWARD -p tcp --dport 80 -i eth0 -m state --state NEW -m recent --set

iptables -I FORWARD -p tcp --dport 80 -i eth0 -m state --state NEW -m recent --update --seconds 60 --hitcount 2 -j DROP

http://pcserver.uk/iptrecent.htm




