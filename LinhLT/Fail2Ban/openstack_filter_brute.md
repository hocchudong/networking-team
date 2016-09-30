Trong bài viết này, tôi sẽ trình bày các tôi viết filter chặn tấn công dò mật khẩu (brute password) vào openstack qua 2 phương thức:
- Chặn trên Dashboard Horizon.
- Chặn trên API (API sử dụng curl, REST Client)

Phiên bản openstack mà tôi sử dụng là bản mitaka.
Mô hình có 2 node: 1 node controller và 1 node compute.
Node controller có 2 dải địa chỉ ip là :
	- card mạng external: 172.16.69.150
	- card mạng internal: 10.10.10.150
#1. Chặn tấn công vào Dashboard
Dashboard mà tôi đang dùng chạy trên nền apache2. Vì vậy, đầu tiên, tôi sẽ kiểm tra file log của apache2.

#1.1 Phân tích file log
###1.1.1 /var/log/apache2/acces.log

```sh
tailf /var/log/apache2/acces.log
```
Tôi tiến hành thử nghiệm khi đăng nhập thành công và đăng nhập thật bại, log sẽ chạy ra như thế nào. 

Và đây là dòng log khi tôi đăng nhập thất bại:
```sh
172.16.69.1 - - [28/Sep/2016:09:48:52 +0700] "POST /horizon/auth/login/ HTTP/1.1" 200 3518 "http://172.16.69.150/horizon/auth/login/" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36"
172.16.69.1 - - [28/Sep/2016:09:48:52 +0700] "GET /horizon/i18n/js/horizon+openstack_dashboard/ HTTP/1.1" 200 2666 "http://172.16.69.150/horizon/auth/login/" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36"
```

Đây là dòng log khi tôi đăng nhập thành công: 
```sh
172.16.69.1 - - [28/Sep/2016:09:49:25 +0700] "POST /horizon/auth/login/ HTTP/1.1" 302 2955 "http://172.16.69.150/horizon/auth/login/" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36"
172.16.69.1 - - [28/Sep/2016:09:49:25 +0700] "GET /horizon/ HTTP/1.1" 302 335 "http://172.16.69.150/horizon/auth/login/" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36"
172.16.69.1 - - [28/Sep/2016:09:49:25 +0700] "GET /horizon/identity/ HTTP/1.1" 200 6182 "http://172.16.69.150/horizon/auth/login/" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36"
172.16.69.1 - - [28/Sep/2016:09:49:26 +0700] "GET /horizon/i18n/js/horizon+openstack_dashboard/ HTTP/1.1" 200 2666 "http://172.16.69.150/horizon/identity/" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36"
```

Các bạn có thể nhận thấy sự khác biệt rõ ràng khi đăng nhập thành công và thất bại rồi chứ?
Tôi sẽ tiến hành phân tích: 
- Khi đăng nhập thất bại, thì response POST được trả về với giá trị http code là 200.
- Khi đăng nhập thành công, thì response POST được trả về với giá trị http code là 302. Bởi vì khi đăng nhập thành công, thì ta 
sẽ được tự động chuyển sang trang quản lý của openstack. Còn ngược lại, khi đăng nhập thất bại thì ta vẫn đứng nguyên ở trang đăng nhập,
không chuyển đi đâu cả.

###1.1.2 /var/log/apache2/error.log

```sh
tailf /var/log/apache2/error.log
```

Cũng tương tự như ở trên, tôi tiến hành thử nghiệm 2 trường hợp thất công và thất bại. Kết quả tôi nhận được là:

Thất bại: 
```sh
[Wed Sep 28 02:48:52.365251 2016] [:error] [pid 2622:tid 140028982589184] Login failed for user "admin".
```

Thành công: 
```sh
[Wed Sep 28 02:32:40.366138 2016] [:error] [pid 2622:tid 140028990981888] Login successful for user "admin".
```

Ở đây, thông báo đã rõ ràng hơn khi có dòng đăng nhập thành công hay đăng nhập thất bại. Tuy nhiên, trong dòng log này không
chứa địa chỉ ip của client nên không thể xác định được client là ai. Vì vậy, tôi bỏ qua file log này. Bạn có thể tìm hiểu thêm
phần tùy chỉnh format log error của apache2 để xem có tùy chỉnh được ip của client vào dòng log này không. Nếu được, các bạn có thể 
trao đổi với tôi nhé :v.

###1.1.3 /var/log/apache2/keystone.log

Nội dung file này giống với file log: `/var/log/keystone/keystone-wsgi-public.log`


```sh
tailf /var/log/apache2/keystone.log
```

Thất bại
```sh
2016-09-30 08:35:41.980174 2016-09-30 08:35:41.979 2819 INFO keystone.common.wsgi [req-328caf86-6cb2-4579-bab7-f4e3ca797449 - - - - -] POST http://10.10.10.150:5000/v3/auth/tokens
2016-09-30 08:35:42.388879 2016-09-30 08:35:42.387 2819 WARNING keystone.common.wsgi [req-328caf86-6cb2-4579-bab7-f4e3ca797449 - - - - -] Authorization failed. The request you have made requires authentication. from 10.10.10.150
```

Thành công: 
```sh
2016-09-30 09:00:51.056160 2016-09-30 09:00:51.055 2819 INFO keystone.common.wsgi [req-14500f49-9914-41a0-bbb5-4c3c32798970 - - - - -] POST http://10.10.10.150:5000/v3/auth/tokens
2016-09-30 09:00:51.124794 2016-09-30 09:00:51.124 2819 INFO keystone.token.providers.fernet.utils [req-14500f49-9914-41a0-bbb5-4c3c32798970 - - - - -] Loaded 2 encryption keys (max_active_keys=3) from: /etc/keystone/fernet-keys/
2016-09-30 09:00:51.136602 2016-09-30 09:00:51.135 2823 INFO keystone.token.providers.fernet.utils [req-7729258c-fdf8-4489-b806-63bd3da1cc1f - - - - -] Loaded 2 encryption keys (max_active_keys=3) from: /etc/keystone/fernet-keys/
2016-09-30 09:00:51.171283 2016-09-30 09:00:51.170 2823 INFO keystone.common.wsgi [req-7729258c-fdf8-4489-b806-63bd3da1cc1f 07cb5ed6335747d981e10d2285341c6c - - 02da35b5f62b49739aaeb49030f30228 -] POST http://10.10.10.150:5000/v3/auth/tokens
2016-09-30 09:00:51.182763 2016-09-30 09:00:51.181 2823 INFO keystone.token.providers.fernet.utils [req-7729258c-fdf8-4489-b806-63bd3da1cc1f 07cb5ed6335747d981e10d2285341c6c - - 02da35b5f62b49739aaeb49030f30228 -] Loaded 2 encryption keys (max_active_keys=3) from: /etc/keystone/fernet-keys/
2016-09-30 09:00:51.292954 2016-09-30 09:00:51.292 2822 INFO keystone.common.wsgi [req-da5683c1-9f29-492c-92db-de1b3ca8fdb2 - - - - -] GET http://10.10.10.150:5000/v3/
2016-09-30 09:00:51.303452 2016-09-30 09:00:51.302 2824 INFO keystone.token.providers.fernet.utils [req-1c710cef-7bec-42ed-92d5-6ae787271ab1 - - - - -] Loaded 2 encryption keys (max_active_keys=3) from: /etc/keystone/fernet-keys/
2016-09-30 09:00:51.336229 2016-09-30 09:00:51.335 2824 INFO keystone.common.wsgi [req-1c710cef-7bec-42ed-92d5-6ae787271ab1 07cb5ed6335747d981e10d2285341c6c - - 02da35b5f62b49739aaeb49030f30228 -] GET http://10.10.10.150:5000/v3/users/07cb5ed6335747d981e10d2285341c6c/projects
2016-09-30 09:00:51.381256 2016-09-30 09:00:51.380 2820 INFO keystone.token.providers.fernet.utils [req-745492e8-b98f-4ed1-8c4e-2045dfd714fb - - - - -] Loaded 2 encryption keys (max_active_keys=3) from: /etc/keystone/fernet-keys/
2016-09-30 09:00:51.412208 2016-09-30 09:00:51.411 2820 INFO keystone.common.wsgi [req-745492e8-b98f-4ed1-8c4e-2045dfd714fb 07cb5ed6335747d981e10d2285341c6c - - 02da35b5f62b49739aaeb49030f30228 -] POST http://10.10.10.150:5000/v3/auth/tokens
2016-09-30 09:00:51.429805 2016-09-30 09:00:51.429 2820 INFO keystone.token.providers.fernet.utils [req-745492e8-b98f-4ed1-8c4e-2045dfd714fb 07cb5ed6335747d981e10d2285341c6c - - 02da35b5f62b49739aaeb49030f30228 -] Loaded 2 encryption keys (max_active_keys=3) from: /etc/keystone/fernet-keys/
2016-09-30 09:00:51.553354 2016-09-30 09:00:51.552 2820 INFO keystone.token.providers.fernet.utils [req-745492e8-b98f-4ed1-8c4e-2045dfd714fb 07cb5ed6335747d981e10d2285341c6c - - 02da35b5f62b49739aaeb49030f30228 -] Loaded 2 encryption keys (max_active_keys=3) from: /etc/keystone/fernet-keys/
2016-09-30 09:00:51.585848 2016-09-30 09:00:51.585 2830 INFO keystone.token.providers.fernet.utils [req-e5527f1d-db6a-4f52-954d-532995af3ff4 - - - - -] Loaded 2 encryption keys (max_active_keys=3) from: /etc/keystone/fernet-keys/
2016-09-30 09:00:51.692302 2016-09-30 09:00:51.691 2830 INFO keystone.common.wsgi [req-e5527f1d-db6a-4f52-954d-532995af3ff4 07cb5ed6335747d981e10d2285341c6c 328e0c1fb9994b17af839acba212ca1b - 02da35b5f62b49739aaeb49030f30228 02da35b5f62b49739aaeb49030f30228] GET http://10.10.10.150:35357/v3/domains/02da35b5f62b49739aaeb49030f30228
2016-09-30 09:00:51.713872 2016-09-30 09:00:51.711 2828 INFO keystone.token.providers.fernet.utils [req-0819e6f7-ba08-43b2-aeca-913e8fc9050a - - - - -] Loaded 2 encryption keys (max_active_keys=3) from: /etc/keystone/fernet-keys/
2016-09-30 09:00:51.812721 2016-09-30 09:00:51.812 2828 INFO keystone.common.wsgi [req-0819e6f7-ba08-43b2-aeca-913e8fc9050a 07cb5ed6335747d981e10d2285341c6c 328e0c1fb9994b17af839acba212ca1b - 02da35b5f62b49739aaeb49030f30228 02da35b5f62b49739aaeb49030f30228] GET http://10.10.10.150:35357/v3/domains/02da35b5f62b49739aaeb49030f30228
2016-09-30 09:00:51.840235 2016-09-30 09:00:51.839 2826 INFO keystone.token.providers.fernet.utils [req-0f145512-c4d1-4e18-a0e4-542653587383 - - - - -] Loaded 2 encryption keys (max_active_keys=3) from: /etc/keystone/fernet-keys/
2016-09-30 09:00:51.940249 2016-09-30 09:00:51.939 2826 INFO keystone.common.wsgi [req-0f145512-c4d1-4e18-a0e4-542653587383 07cb5ed6335747d981e10d2285341c6c 328e0c1fb9994b17af839acba212ca1b - 02da35b5f62b49739aaeb49030f30228 02da35b5f62b49739aaeb49030f30228] GET http://10.10.10.150:35357/v3/projects?domain_id=02da35b5f62b49739aaeb49030f30228
2016-09-30 09:00:51.957070 2016-09-30 09:00:51.956 2825 INFO keystone.token.providers.fernet.utils [req-da6adcd4-7c46-4c18-aa98-25b727a441cd - - - - -] Loaded 2 encryption keys (max_active_keys=3) from: /etc/keystone/fernet-keys/
2016-09-30 09:00:52.066494 2016-09-30 09:00:52.065 2825 INFO keystone.common.wsgi [req-da6adcd4-7c46-4c18-aa98-25b727a441cd 07cb5ed6335747d981e10d2285341c6c 328e0c1fb9994b17af839acba212ca1b - 02da35b5f62b49739aaeb49030f30228 02da35b5f62b49739aaeb49030f30228] GET http://10.10.10.150:35357/v3/domains
2016-09-30 09:00:52.086448 2016-09-30 09:00:52.084 2822 INFO keystone.token.providers.fernet.utils [req-b06d09ed-51dc-490e-b845-564df954951f - - - - -] Loaded 2 encryption keys (max_active_keys=3) from: /etc/keystone/fernet-keys/
2016-09-30 09:00:52.120525 2016-09-30 09:00:52.120 2822 INFO keystone.common.wsgi [req-b06d09ed-51dc-490e-b845-564df954951f 07cb5ed6335747d981e10d2285341c6c - - 02da35b5f62b49739aaeb49030f30228 -] GET http://10.10.10.150:5000/v3/users/07cb5ed6335747d981e10d2285341c6c/projects
2016-09-30 09:00:52.200224 2016-09-30 09:00:52.198 2828 INFO keystone.common.wsgi [req-0819e6f7-ba08-43b2-aeca-913e8fc9050a 07cb5ed6335747d981e10d2285341c6c 328e0c1fb9994b17af839acba212ca1b - 02da35b5f62b49739aaeb49030f30228 02da35b5f62b49739aaeb49030f30228] GET http://10.10.10.150:35357/
2016-09-30 09:00:52.215694 2016-09-30 09:00:52.215 2830 INFO keystone.common.wsgi [req-0f0b9cc3-63e0-47fa-81cb-7c1fd1c83491 - - - - -] POST http://10.10.10.150:35357/v3/auth/tokens
2016-09-30 09:00:52.425398 2016-09-30 09:00:52.424 2830 INFO keystone.token.providers.fernet.utils [req-0f0b9cc3-63e0-47fa-81cb-7c1fd1c83491 - - - - -] Loaded 2 encryption keys (max_active_keys=3) from: /etc/keystone/fernet-keys/
2016-09-30 09:00:52.435743 2016-09-30 09:00:52.434 2825 INFO keystone.common.wsgi [req-687ba408-19d6-4bdb-ade0-d85a6981c951 - - - - -] GET http://10.10.10.150:35357/v3/
2016-09-30 09:00:52.449436 2016-09-30 09:00:52.448 2826 INFO keystone.token.providers.fernet.utils [req-61221c17-fb49-4f1b-b880-9af7e1b566a3 - - - - -] Loaded 2 encryption keys (max_active_keys=3) from: /etc/keystone/fernet-keys/
2016-09-30 09:00:52.624251 2016-09-30 09:00:52.623 2826 INFO keystone.common.wsgi [req-61221c17-fb49-4f1b-b880-9af7e1b566a3 65cd8866d34f40d0bcde215ef41bfac7 0e65881b844f47c9a5fabf86e12cfeb5 - 02da35b5f62b49739aaeb49030f30228 02da35b5f62b49739aaeb49030f30228] GET http://10.10.10.150:35357/v3/auth/tokens
2016-09-30 09:00:52.626841 2016-09-30 09:00:52.625 2826 INFO keystone.token.providers.fernet.utils [req-61221c17-fb49-4f1b-b880-9af7e1b566a3 65cd8866d34f40d0bcde215ef41bfac7 0e65881b844f47c9a5fabf86e12cfeb5 - 02da35b5f62b49739aaeb49030f30228 02da35b5f62b49739aaeb49030f30228] Loaded 2 encryption keys (max_active_keys=3) from: /etc/keystone/fernet-keys/
2016-09-30 09:00:52.725710 2016-09-30 09:00:52.724 2826 INFO keystone.token.providers.fernet.utils [req-61221c17-fb49-4f1b-b880-9af7e1b566a3 65cd8866d34f40d0bcde215ef41bfac7 0e65881b844f47c9a5fabf86e12cfeb5 - 02da35b5f62b49739aaeb49030f30228 02da35b5f62b49739aaeb49030f30228] Loaded 2 encryption keys (max_active_keys=3) from: /etc/keystone/fernet-keys/
```

Nhìn vào phần log đăng nhập thất bại, ta thấy được nội dung rất rõ ràng là:
```sh
Authorization failed. The request you have made requires authentication. from 10.10.10.150

Tuy nhiên, địa chỉ ip ở đây là `10.10.10.150`, là địa chỉ ip của chính controller. Tức có nghĩa là khi người dùng ở mạng ngoài
gửi một yêu cầu đăng nhập, thì ở đây phần keystone trên chính máy controller sẽ thực hiện xác thực, do đó, địa chỉ ip của client
đã được thay thế thành địa chỉ ip của keystone. Vì vậy, tôi cũng loại bỏ luôn trường hợp này.

###1.1.4 /var/log/apache2/keystone_access.log

```sh
root@controller:/var/log/apache2# tailf keystone_access.log 
```

Thất bại:

```sh
10.10.10.150 - - [30/Sep/2016:08:35:37 +0700] "POST /v3/auth/tokens HTTP/1.1" 401 489 "-" "keystoneauth1/2.4.0 python-requests/2.9.1 CPython/2.7.6"
```

Thành công: 

```sh
10.10.10.150 - - [30/Sep/2016:08:59:21 +0700] "POST /v3/auth/tokens HTTP/1.1" 201 800 "-" "keystoneauth1/2.4.0 python-requests/2.9.1 CPython/2.7.6"
10.10.10.150 - - [30/Sep/2016:08:59:25 +0700] "POST /v3/auth/tokens HTTP/1.1" 401 488 "-" "keystoneauth1/2.4.0 python-requests/2.9.1 CPython/2.7.6"
10.10.10.150 - - [30/Sep/2016:08:59:26 +0700] "GET /v3 HTTP/1.1" 200 556 "-" "keystoneauth1/2.4.0 python-requests/2.9.1 CPython/2.7.6"
10.10.10.150 - - [30/Sep/2016:08:59:26 +0700] "GET /v3/users/07cb5ed6335747d981e10d2285341c6c/projects HTTP/1.1" 200 769 "-" "python-keystoneclient"
10.10.10.150 - - [30/Sep/2016:08:59:26 +0700] "POST /v3/auth/tokens HTTP/1.1" 201 3431 "-" "keystoneauth1/2.4.0 python-requests/2.9.1 CPython/2.7.6"
10.10.10.150 - - [30/Sep/2016:08:59:26 +0700] "GET /v3/domains/02da35b5f62b49739aaeb49030f30228 HTTP/1.1" 200 521 "-" "python-keystoneclient"
10.10.10.150 - - [30/Sep/2016:08:59:26 +0700] "GET /v3/domains/02da35b5f62b49739aaeb49030f30228 HTTP/1.1" 200 521 "-" "python-keystoneclient"
10.10.10.150 - - [30/Sep/2016:08:59:27 +0700] "GET /v3/projects?domain_id=02da35b5f62b49739aaeb49030f30228 HTTP/1.1" 200 1728 "-" "python-keystoneclient"
10.10.10.150 - - [30/Sep/2016:08:59:27 +0700] "GET /v3/domains HTTP/1.1" 200 615 "-" "python-keystoneclient"
10.10.10.150 - - [30/Sep/2016:08:59:27 +0700] "GET /v3/users/07cb5ed6335747d981e10d2285341c6c/projects HTTP/1.1" 200 770 "-" "python-keystoneclient"
10.10.10.150 - - [30/Sep/2016:08:59:27 +0700] "GET /v3/auth/tokens HTTP/1.1" 200 3427 "-" "python-keystoneclient"

```

Tương tự như ở trên, địa chỉ ip của client đã được thay thế bằng địa chỉ ip của phần keystone. Đồng thơi, trong file log đăng nhập
thành công có 2 đoạn POST với mã 201 và 401, dẫn đến khó khăn trong việc nhận dạng đăng nhập thành công hay thất bại.

Cuối cùng, tôi đi đến quyết định, sử dụng file log trong trường hợp đầu tiên để nhận dạng kẻ tấn công.

##1.2 Viết filter

Nội dung file log khi đăng nhập thành công:
```sh
172.16.69.1 - - [28/Sep/2016:09:49:25 +0700] "POST /horizon/auth/login/ HTTP/1.1" 302 2955 "http://172.16.69.150/horizon/auth/login/" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36"
```

Nội dung file log khi đăng nhập thất bại:
```sh
172.16.69.1 - - [28/Sep/2016:09:48:52 +0700] "POST /horizon/auth/login/ HTTP/1.1" 200 3518 "http://172.16.69.150/horizon/auth/login/" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36"
```

Và cuối cùng, nội dung file filter của tôi: `/etc/fail2ban/filter.d/openstack2.conf`

```sh
# Fail2Ban filter for openstack horizon 
#dir log: /var/log/apache2/access.log

[Definition]

failregex = ^<HOST> - - \[(.*?)\] "POST \/horizon\/auth\/login\/ HTTP\/1.1" 200

ignoreregex = 
```
- Giải thích:

```sh
	- ký tự `^`: Bắt đầu tiếm kiếm giá trị từ đầu chuỗi.
	- `<HOST>`: Khi có biến host, fail2ban sẽ tự nhận diện địa chỉ ip.
	- \[(.*?)\]: Get thời gian tỏng file log.
	- `"POST \/horizon\/auth\/login\/ HTTP\/1.1" 200`: Tìm đoạn nội dung này trong file log.
```

##1.3 File jail: `/etc/fail2ban/jail.d/openstack2.conf`

```sh
[openstack2]

enabled  = true
port     = 80
filter   = openstack2 
logpath  = /var/log/apache2/access.log
maxretry = 3 
```

- Giải thích:
	- enabled = true: Cho phép jail này chạy.
	- port = 80: Cổng.
	- filter   = openstack2 : Chỉ ra file filter trong thư mục filter.d
	- logpath  = /var/log/apache2/access.log: Đường dẫn file log.
	- maxretry = 3 : Số lần thử tối đa.

Các thông số còn lại tôi để mặc định.

##1.4 Kết quả:
Khi tôi cố tình đăng nhập sai 3 lần liên tục trong 10s, kết quả tôi nhận được là:

![](http://image.prntscr.com/image/aec7b979925140eeb4b64e57cc092c2c.png)

![](http://image.prntscr.com/image/5ff485b7b7ba4dc8a50510053875ae65.png)

#2. Chặn tấn công dựa trên API.
Trong phần này, tôi có viết một đoạn php để kiểm tra user có đăng nhập được hay không, thông qua API sử dụng curl của OpenStack.

Dựa vào file này, tôi sẽ tiến hành tấn công mật khẩu.

Nội dung file tôi để trong thư mục: https://github.com/lethanhlinh247/networking-team/tree/master/LinhLT/Fail2Ban/curl

Để hiểu rõ hơn về các API của OpenStack, các bạn tham khảo tại đây: http://developer.openstack.org/api-ref/identity/v3/index.html

##2.1 Phân tích log.
###2.1.1 /var/log/apache2/keystone_access.log
Đăng nhập thất bại:

```sh
172.16.69.1 - - [30/Sep/2016:09:43:56 +0700] "POST /v3/auth/tokens HTTP/1.1" 401 435 "-" "-"
```

Đăng nhập thành công:
```sh
172.16.69.1 - - [30/Sep/2016:09:47:11 +0700] "POST /v3/auth/tokens HTTP/1.1" 201 744 "-" "-"
```

OK, ta dễ dàng nhận ra được là khi đăng nhập thất bại, response POST có http code là 401.
Ngược lại, đăng nhập thành công, response POST có http code là 201.

###2.1.2 /var/log/keystone/keystone-wsgi-admin.log 
Nội dung file log này tương đương với file log ở: `/var/log/apache2/keystone.log`

Đăng nhập thất bại: 
```sh
2016-09-30 10:00:59.326 2830 INFO keystone.common.wsgi [req-81ea6296-c0d7-47d1-b30d-1f4a9b3ec7c2 - - - - -] POST http://172.16.69.150:35357/v3/auth/tokens
2016-09-30 10:00:59.387 2830 WARNING keystone.common.wsgi [req-81ea6296-c0d7-47d1-b30d-1f4a9b3ec7c2 - - - - -] Authorization failed. The request you have made requires authentication. from 172.16.69.1
```

Đăng nhập thành công: 
```sh
2016-09-30 10:01:44.693 2825 INFO keystone.common.wsgi [req-2d1d9b1c-b6b4-4a4a-aff3-f432105c9c07 - - - - -] POST http://172.16.69.150:35357/v3/auth/tokens
2016-09-30 10:01:44.775 2825 INFO keystone.token.providers.fernet.utils [req-2d1d9b1c-b6b4-4a4a-aff3-f432105c9c07 - - - - -] Loaded 2 encryption keys (max_active_keys=3) from: /etc/keystone/fernet-keys/
```

Phần nội dung của file log này đầy đủ hơn so với file trên kia.

Ở đây, khi đăng nhập thất bại, file log trả về nội dung `Authorization failed. The request you have made requires authentication. from 172.16.69.1`.
Còn nếu đăng nhập thành công, keystone sẽ tiến hành tạo key.

Do đó, tôi quyết định sẽ dựa vào phần nội dung của file log này để viết nên filter.

##2.2 Viết filter:

Tôi sẽ dựa vào dòng này để viết filter: 
```sh
2016-09-30 10:00:59.387 2830 WARNING keystone.common.wsgi [req-81ea6296-c0d7-47d1-b30d-1f4a9b3ec7c2 - - - - -] Authorization failed. The request you have made requires authentication. from 172.16.69.1

```

Nội dung file filter của tôi là: `/etc/fail2ban/filter.d/openstack.conf`

```sh
# Fail2Ban filter for OpenStack API 
#dir log: /var/log/keystone/keystone-wsgi-admin.log
[Definition]

failregex = ^(.*?) (.*?) (.*?)WARNING keystone.common.wsgi \[(.*?)\] Authorization failed\. The request you have made requires authentication\. from <HOST>$ 

ignoreregex = 
```

- Giải thích: 

```sh
	- ký tự ^: Bắt đầu tiếm kiếm giá trị từ đầu chuỗi.
	- 3 tập ký hiệu liên tiếp: (.*?): Đại diện cho các nội dung: `2016-09-30`, `10:00:59.387` và `2830`.
	- \[(.*?)\]: Đại diện cho [req-81ea6296-c0d7-47d1-b30d-1f4a9b3ec7c2 - - - - -]
	- <HOST>: Nhận dạng địa chỉ ip của client.
	- ký tự $: Kết thúc chuỗi.
```

##2.3 File jail: `/etc/fail2ban/jail.d/openstack.conf`

```sh
[openstack]

enabled  = true
port     = 35357 
filter   = openstack 
logpath  = /var/log/keystone/keystone-wsgi-admin.log
maxretry = 3 
```

- Các thông số tôi đã giải thích ở trên. Tuy nhiên, các bạn chú ý một số điểm sau:
	- port = 35357: Port dùng trong API.
	- logpath: Đường dẫn file log khác so với trên kia.

##2.4 Kết quả:

![](http://image.prntscr.com/image/f6a29c591a8240dc87e2153f603457fe.png)

![](http://image.prntscr.com/image/6342a092b1fa4b73ba89f022a3f866a1.png)