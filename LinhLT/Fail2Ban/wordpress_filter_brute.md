#Filter chặn brute password cho blog wordpress.

Ở phần này, tôi sẽ trình bày cách mà tôi viết filter, chặn brute password vào blog của tôi. Blog của tôi sử dụng 
mã nguồn wordpress.

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