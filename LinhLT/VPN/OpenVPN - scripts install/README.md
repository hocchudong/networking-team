#README
Hướng dẫn sử dụng scripts cài đặt OpenVPN mô hình site to site trên nền tảng ubuntu 14.04
#1. Mô hình:


#2. Thiết lập các thông số trên cả 2 site
- Tải file `config.cfg`, thay đổi các thông số phù hợp với mô hình của bạn.
- Chú ý, các bạn phải tải file này về ở cả 2 site.
```sh
cd /root/
wget 
```

```sh
#########
ip_public_local=172.16.69.131
ip_public_remote=172.16.69.132
port=1194
ip_tunnel_local=10.0.0.1
ip_tunnel_remote=10.0.0.2
dir_key=/etc/openvpn/vpn.key
net_lan_remote=10.10.20.0
mask_lan_remote=255.255.255.0
user=root	#user for login ssh on site remote.
dir_log=/var/log/openvpn
dir_openvpn=/etc/openvpn
```
#3. Chạy trên site A.
Tải file `install_openvpn.sh` về, phân quyền cho phép thực thi file và chạy file.
Lưu ý, file `config.cfg` phải nằm cùng thư mục với file `install_openvpn.sh`.
```sh
cd /root/
wget 
chmod u+x 
./install_openvpn.sh
```

#4. Trên site A.
Tải file `genkey.sh` về,  phần quyền cho phép thực thi file và chạy file.
Lưu ý, trong quá trình chạy scripts, sẽ có yêu cầu thông báo nhập mật khẩu ssh để truy cập đến site B từ site A, phục vụ cho mục đích chép file key vpn từ site A sang site B. Nếu các bạn đã cấu hình ssh trên site A và site B bằng cách sử dụng file key thì không cần phải nhập mật khẩu.

```sh
cd /root/
wget
chmod u+x
./genkey.sh
```

#5. Trên site B.
Tiến hành khởi động lại dịch vụ openvpn
```sh
service openvpn restart
```

#6. Tận hưởng kết quả :)).

