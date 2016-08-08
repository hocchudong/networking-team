#LAB - Sử dụng iptables để ngăn chặn cuộc tấn công dos
#Mô hình

![](http://i.imgur.com/tDAbv1U.jpg)

Giả lập tấn công:
Attacker liên tục gửi các request đến Webserver, khiến Webserver không thể xử lý kịp, dẫn đến tình trạng không thể đáp ứng yêu cầu của client.

```sh
Webserver: 10.10.10.135, chạy apache2 và mysql
Chạy wordpress tại địa chỉ http://10.10.10.135/wordpress

Máy attacker: 10.10.10.128
Chạy tools `wrk` phục vụ tấn công dos.
```
#Trên máy Attacker
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


 #Trên Webserver
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

- Kết quả sau khi ngăn chặn

![](http://image.prntscr.com/image/d55f1e5baaec4ec99c304cfb7392a49f.png)


![](http://i.imgur.com/UHPJSiP.png)
