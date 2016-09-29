# Nội dung
Bài viết này gồm 2 phần:
- Phần 1: Tôi sẽ trình bày cách mà tôi viết filter chặn brute password.
- PHân 2: Tôi sẽ hướng dẫn cách cấu hình để server sẽ tự động gửi email thông báo cho người quản trị.

#1. Filter chặn brute password cho blog wordpress.

Ở phần này, tôi sẽ trình bày cách mà tôi viết filter, chặn brute password vào blog của tôi. Blog của tôi sử dụng 
mã nguồn wordpress, chạy trên apache2, trên hệ điều hành ubuntu server 14.04.

Vào một ngày đẹp trời, tôi nhâm nhi ly cafe và login vào server thông qua ssh để kiểm tra hoạt động của server.
Đập vào mắt tôi là hàng trăm dòng log đăng nhập thất bại vào blog wordpress với tài khoản admin. Lập tức, tôi nghĩ ngay đến việc phải
chăng có một anh chàng đẹp trai nào đang tiến hành brute password admin vào blog của tôi???. Blog của tôi có cái gì đâu mà khiến 
anh chàng kia để ý nhỉ :))). Dưới đây là một phần log mà tôi trích ra.
```sh
root@adk:~# tailf /var/log/apache2/access.log

10.10.10.1 - - [22/Sep/2016:08:44:27 +0700] "POST /wordpress/wp-login.php HTTP/1.1" 200 1886 "http://10.10.10.150/wordpress/wp-login.php?redirect_to=http%3A%2F%2F10.10.10.150%2Fwordpress%2Fwp-admin%2F&reauth=1" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36"

10.10.10.1 - - [22/Sep/2016:08:45:17 +0700] "POST /wordpress/wp-login.php HTTP/1.1" 200 1886 "http://10.10.10.150/wordpress/wp-login.php" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36"
```

Làm thế nào để chặn thằng ku này nhỉ?. Tôi nghĩ ngay đến việc sử dụng IPTables để block ip của thằng ku này :)). Chỉ đơn giản 
với rules như sau :
```sh
iptables -A INPUT -p tcp --dport 80 -s 10.10.10.1 -j DROP
```
OK thế là xong, thằng ku này sẽ hết táy máy brute blog của tôi nữa. :D

Nhưng mà một vấn đề đặt ra là, giả sử thằng ku này "nóng máu" lên, nó kêu gọi toàn thể anh em tiến hành brute admin blog của tôi thì sao?
Chả nhẽ tôi lại đi block bằng tay từng thằng một? Mà lỡ "đồng bọn" của ku này ra quán net cắm tools brute. Khi đó, tôi đã vô tình
block luôn ip của quán nét đó. Giả sử có một bạn gái xinh đẹp muốn vào blog của tôi để làm quen thì sao??? Như vậy là tôi đã đánh
mất cơ hội thoát kiếp FA của mình =)).

OK, để giải quyết những vấn đề trên, tôi nghĩ ngay đến việc sử dụng fail2ban. Fail2ban sẽ tiến hành theo dõi các file log và 
đưa ra các rules cho IPTables chặn những ip tấn công. Đặc biệt nữa là, sau một khoảng thời gian mà tôi cài đặt, fail2ban sẽ tiến hành
xóa rules đó đi. Điều nay giúp tôi linh hoạt trong việc ban và unban các địa chỉ ip đấy. 

Vì fail2ban sẽ tiến hành đọc, theo dõi các file log, cho nên tôi thử tiến hành đăng nhập vào blog bằng tài khoản admin để xem
log được ghi lại như thế nào.
```sh
root@adk:~# tailf /var/log/apache2/access.log

10.10.10.1 - - [22/Sep/2016:08:45:38 +0700] "POST /wordpress/wp-login.php HTTP/1.1" 302 1168 "http://10.10.10.150/wordpress/wp-login.php" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36"
10.10.10.1 - - [22/Sep/2016:08:45:38 +0700] "GET /wordpress/wp-admin/ HTTP/1.1" 200 14128 "http://10.10.10.150/wordpress/wp-login.php" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36"
```

- OK, các bạn thấy sự khác biệt khi đăng nhập thành công và đăng nhập thất bại rồi chứ? So sánh 2 đoạn log mà tôi đã cung cấp ở 
trên cho thấy:
	- Nếu bạn đăng nhập thành công, blog sẽ tiến hành chuyển hướng sang trang `/wordpress/wp-admin/` với http code là `302`.
	- Nếu bạn đăng nhập thất bại, blog sẽ vẫn đứng yên ở trang này, với http code là `200`.

OK, giờ tôi sẽ dựa vào `http code` để nhận dạng được kẻ tấn công. :D

Tôi lập tức viết một biểu thức chính quy để fail2ban nhận dạng được kẻ tấn công là ai :D
```sh
root@adk:~# vi /etc/fail2ban/filter.d/wp.confg

[Definition]
failregex = ^<HOST>.*"POST \/wordpress\/wp-login\.php HTTP\/1\.1" 200
ignoreregex =  
```

- Phân tích biểu thức chính quy: 
	- Ký tự `^` dùng để bắt đầu tìm kiếm tra từ đầu chuỗi.
	- `<HOST>`: Dùng để bắt địa chỉ ip trong file log.
	- `.*"POST \/wordpress\/wp-login\.php HTTP\/1\.1" 200` dùng để tìm kiếm chuỗi `"POST \/wordpress\/wp-login\.php HTTP\/1\.1" 200` trong log.

- Để các bạn hình dung dễ hơn, tôi đưa vào ảnh bên dưới. Chú ý là ở đây tôi thay thế `HOST` bằng địa chỉ IP bởi vì fail2ban hiểu được biến `HOST` còn trên trang này thì không :D

![](http://image.prntscr.com/image/43a984eb107445b49f0a2917f68e11d0.png)

Chỉ với dòng lệnh đơn giản như vậy, fail2ban sẽ nhận ra được những ip nào (dựa vào biến HOST) đăng nhập thất bại.

Sau đó, tôi sẽ đặt một vài thiết lập như đăng nhập thất bại mấy lần thì sẽ bị block,..
```sh
root@adk:~# vi /etc/fail2ban/jail.d/wp.confg

[wp]
enabled = true
filter = wp
action = iptables-multiport[name=wp, port="http,https", protocol="tcp", chain="INPUT"]
logpath = /var/log/apache2/access.log
bantime = 1200
maxretry = 3
findtime = 60
```

- Ở đây, tôi đã thiết lập:
	- Đăng nhập thất bại 3 lần trong vòng 1 phút thì sẽ bị block. Thời gian bị block 20 phút :)). Sau 20 phút, fail2ban sẽ tự động unban.
	- `/var/log/apache2/access.log` là đường dẫn file log mà blog của tôi được ghi lại.
	- `action = iptables-multiport[name=wp, port="http", protocol="tcp", chain="INPUT"]` Dòng này chỉ rõ khi đạt đến giới hạn, thì fail2ban
	sẽ xử lý như thế nào. Trong fail2ban có sẵn một file hành động tên `iptables-multiport` giúp fail2ban tương tác các rules với
	IPTables. Ở đây tôi sử dụng lại luôn thằng này. Nếu các bạn không thích, có thể tự viết ra một file hành động riêng :)).

Kết quả mà tôi nhận được
![](http://image.prntscr.com/image/da1f722d4f794d549eba3518c85b9d82.png)


Cuối cùng, tôi xin giới thiệu 2 trang web giúp cho bạn dễ dàng hơn trong việc viết các biểu thức chính quy ^^!. Đó là: 
- http://regexr.com/
- https://regex101.com/

Chúc các bạn vui vẽ :))

#2. Gửi mail thông báo cho người quản trị.
Bạn muốn vừa đi du lịch vừa theo dõi được tình trạng hoạt động của fail2ban,...

Thì ở phần này, tôi sẽ hướng dẫn bạn cấu hình để server có thể tự động gửi các email thông báo đến cho bạn với những nội dung như:

	- Fail2ban bắt đầu hoạt động.
	- Fail2ban tiến hành cấm một địa chỉ ip.
	- Fail2ban vì một lý do nào đấy mà bị dừng lại.
	- ....

Để gửi được mail thì tôi tiến hành cài đặt `Postfix`. `Postfix` là chương trình mã nguồn mở và miễn phí (free and open-source) dùng để gửi thư điện tử (Mail Transfer Agent – MTA.
Sau đó, tôi sẽ cấu hình chuyển tiếp các thư thông qua tài khoản gmail của tôi (use Gmail as a Mail Relay). 

- Đầu tiên, chúng ta cần cài đặt các gói sau:

```sh
sudo apt-get install postfix mailutils libsasl2-2 ca-certificates libsasl2-modules
```
- Tiếp theo, ta cần cấu hình `postfix` sử dụng smtp của gmail.

```sh
vi /etc/postfix/main.cf

relayhost = [smtp.gmail.com]:587
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_tls_CAfile = /etc/postfix/cacert.pem
smtp_use_tls = yes
```
- Tạo file chứa tên đăng nhập và mật khẩu Gmail của bạn.

```sh
vi /etc/postfix/sasl_passwd

[smtp.gmail.com]:587    USERNAME@gmail.com:PASSWORD
```
Trong đó: thay thế **USERNAME** và **PASSWORD** bằng tên đăng nhập và mật khẩu gmail của bạn. (Đây là địa chỉ mail dùng để gửi đi)

- Phân quyền và cập nhật file này cho `postfix`:

```sh
sudo chmod 400 /etc/postfix/sasl_passwd
sudo postmap /etc/postfix/sasl_passwd
```

- Validate các certificates

```sh
cat /etc/ssl/certs/Thawte_Premium_Server_CA.pem | sudo tee -a /etc/postfix/cacert.pem
```

Nếu bạn chưa có file `Thawte_Premium_Server_CA.pem` thì nội dung của file đấy có thể truy cập ở đây

```sh
https://www.thawte.com/roots/thawte_Premium_Server_CA.pem
```

- Khởi động lại `postfix`:

```sh
sudo /etc/init.d/postfix reload
```

- Cho phép tài khoản gmail được truy cập từ các ứng dụng khác.

Các bạn truy cập vào đường link dưới và nhấn vào nút bật. :D

```sh
https://www.google.com/settings/security/lesssecureapps
```

- Thử nghiệm gửi mail

```sh
echo "Test mail from postfix" | mail -s "Test Postfix" xxxxxxxx@gmail.com
```

- Kết quả: 

![](http://i.imgur.com/Kn3vZG6.png)

- Tiếp theo, bạn cấu hình fail2ban sao cho hành động của nó là vừa cấm địa chỉ ip đồng thời gửi email cảnh báo cho người quản trị.
Tôi sẽ cấu hình nó trong file `jail.conf`. Các thông số dưới đây là thông số mặc định, tức là nếu bạn không cấu hình cho một dịch vụ
nào đó, thì nó sẽ lấy các thông số này để hoạt động.

```sh
destemail = xxxxxxxxx@gmail.com
sendername = Fail2Ban
mta = mail
action = %(action_mwl)s
```

- Trong đó:
	- destemail: Địa chỉ email người nhận.
	- sendername: Tên người gửi :D
	- mta = mail: Chỉ ra file action gửi mail. Trong thư mục `action.d` có file mail dùng để gửi email đi. 
	- action = %(action_mwl)s: Quy định hành động fail2ban. Ở đây nó sẽ gọi đến hành động `action_mwl` đã được cấu hình sẵn. (Cấm ip và gửi email cảnh báo.)

- Kết quả:

![](http://image.prntscr.com/image/13e8872fef0340ab9e756f8ef2b4679f.png)


- Để dò lỗi, các bạn hãy đọc file log:

```sh
$ tailf /var/log/mail.log
```

#3. Tham khảo: 
- https://community.runabove.com/kb/en/instances/how-to-relay-postfix-mails-via-smtp.gmail.com-on-ubuntu-14.04.html
- https://easyengine.io/tutorials/linux/ubuntu-postfix-gmail-smtp/