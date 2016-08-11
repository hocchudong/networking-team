#LAB - Sử dụng iptables để ngăn chặn Webserver bị attacker gửi các request liên tục
#Mục Lục
- [1. Mô hình](#mohinh)
- [2. Thực hiện](#thuchien)
  - [2.1 Trên máy Attacker](#attacker)
  - [2.2 Trên Webserver](#webserver)
- [3. Kết quả](#ketqua)
- [4. Mở rộng](#morong)

<a name="mohinh"></a>
#1. Mô hình

![](http://i.imgur.com/tDAbv1U.jpg)

Giả lập tấn công:
Attacker liên tục gửi các request đến Webserver, khiến Webserver không thể xử lý kịp, dẫn đến tình trạng không thể đáp ứng yêu cầu của client.

```sh
Webserver: 10.10.10.135, chạy apache2 và mysql
Chạy wordpress tại địa chỉ http://10.10.10.135/wordpress

Máy attacker: 10.10.10.128
Chạy tools `wrk` phục vụ tấn công dos.
```

<a name="thuchien"></a>
2. Thực hiện
<a name="attacker"></a>
##2.1 Trên máy Attacker
- tools `wrk`
```sh
apt-get install wrk
```
- Thực hiện tấn công
```sh
 wrk -c 600 -t 500 -d 100 http://10.10.10.135/wordpress/index.php
 #Gửi 600 connection, 500 threads, thời gian tấn công: 100s
 ```

- Kết quả: Client không thể truy cập được trang web

  ![](http://i.imgur.com/mfDEBVY.png)

<a name="webserver"></a>
 #2.2. Trên Webserver
 - SysAD thực hiện kiểm tra các tác vụ đang chạy
 ```sh
root@adk# top
 ```

 ![](http://image.prntscr.com/image/ea52ddce5ea34e60979fb3125a8ea080.png)

 **=> CPU chạy trên 90%, service apache2 chiếm cpu rất nhiều.**

- Thực hiện check log apache2
```sh
tailf /var/log/apache2/access.log
```
![](http://image.prntscr.com/image/3ba30017d4764e6798fc03d52aa0dceb.png)

=> Có rất nhiều request được gửi từ địa chỉ IP **10.10.10.128** đến Webserver.

=> Giải pháp, Sử dụng tường lửa iptables ngăn chặn request đến từ địa chỉ ip 10.10.10.128

```sh
root@adk# iptables -I INPUT -s 10.10.10.128 -p tcp --dport 80 -j DROP
```

<a name="ketqua"></a>
#3. Kết quả
- Kết quả sau khi ngăn chặn

![](http://image.prntscr.com/image/d55f1e5baaec4ec99c304cfb7392a49f.png)


![](http://i.imgur.com/UHPJSiP.png)

<a name="morong"></a>
#4. Mở rộng
- Giả sử bạn bị tấn công với rất nhiều địa chỉ ip khác nhau (DDOS), thì công việc đọc log vào block ip như ở trên sẽ gặp rất nhiều khó khăn.
- Vì vậy, phần này mình sẽ giới thiệu module recent của iptables, có chức năng tự động block các ip đang gửi các request có hại đến webserver.
- Câu lệnh: 
```sh
iptables -A INPUT -p tcp --dport 80 -i eth0 -m state --state NEW -m recent --name http --set 
iptables -A INPUT -p tcp --dport 80 -i eth0 -m state --state NEW -m recent --name http --update --seconds 20 --hitcount 11 -j DROP
```
- Giải thích: 
- Dòng 1: iptables sẽ tạo ra một danh sách có tên là http để chứa các địa chỉ ip. Các địa chỉ ip nào bắt đầu khởi tạo kết nối đến webserver sẽ bị liệt kê vào danh sách đó.
- Dòng 2: Cứ mỗi 20s mà có hơn 11 kết nối thì sẽ chặn kết nối. Cụ thể là chặn ip của máy tạo ra kết nối này.

- Danh sách các địa chỉ ip nằm ở đường dẫn: `/proc/net/xt_recent/`



