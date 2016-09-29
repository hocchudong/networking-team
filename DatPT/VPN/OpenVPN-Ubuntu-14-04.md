#Triển Khai VPN bằng OpenVPN trên Ubuntu server 14.04.

![images](http://i.imgur.com/1dFEFcb.png)

**Mục Lục**

****

##I. Mô hình.

##II. Các bước thực hiện.

**Lưu ý**

- Tất cả đều thực hiện dưới quyền `root`.

###1. Cài đặt và cấu hình OpenVPN server.

- Trước tiên chúng ta update danh sách Ubuntu's repository.

```sh
apt-get update
```

- Sau đó chúng ta cần cài đặt `OpenVPN` và `Easy-RSA`

```sh
apt-get install openvpn easy-rsa
```

- Trích xuất tập tin cấu hình vào `/etc/openvpn`

```sh
gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz > /etc/openvpn/server.conf
```

- Chỉnh sửa file `server.conf` , mở nó bằng trình soạn thảo `vi`

```sh
vi /etc/openvpn/server.conf
```

Chúng ta cần chỉnh sửa một số tùy chọn như sau :

![scr1](http://i.imgur.com/wgFMzq5.png)

- Sửa thành :

![scr2](http://i.imgur.com/6Gi4bQl.png)

- Tìm và bỏ dấu ";" đằng trước các dòng sau :

```sh
;push "redirect-gateway def1 bypass-dhcp"
;push "dhcp-option DNS 208.67.222.222"
;push "dhcp-option DNS 208.67.220.220"
;user nobody
;group nogroup
```

- Chuyển thành :

```sh
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 208.67.222.222"
push "dhcp-option DNS 208.67.220.220"
user nobody
group nogroup
```
- `SAVE` lại.

- Kích hoạt tính năng chuyển tiếp gói tin :

```sh
echo 1 > /proc/sys/net/ipv4/ip_forward
```

- Sử dụng lệnh trên chỉ có tác dụng 1 lần, để có thể sử dụng nhiều lần sau khi reboot máy chủ chúng ta cần phải chỉnh sửa
bên trong file sau :

```sh
vi /etc/sysctl.conf
```

- Tìm và bỏ comment dòng sau :

```sh
# Uncomment the next line to enable packet forwarding for IPv4
#net.ipv4.ip_forward=1
```

- Chuyển thành :

```sh
# Uncomment the next line to enable packet forwarding for IPv4
net.ipv4.ip_forward=1
```

- Lưu lại thay đổi và thoát ra.

###2. Thiết lập Firewall.

- Đầu tiên chúng ta cần cho phép được thực hiện SSH bằng lệnh sau:

```sh
ufw allow ssh
```

- Cho phép traffic UDP đi qua port 1194 (port của VPN) 

```sh
ufw allow 1194/udp
```

- Thiếp lập policy :

```sh
vi /etc/default/ufw
```

- Chỉnh sửa dòng sau :

```sh
DEFAULT_FORWARD_POLICY="DROP"
```

- CHuyển thành :

```sh
DEFAULT_FORWARD_POLICY="ACCEPT"
```

- Tiếp theo chúng ta cần add thêm các rules để cho traffic từ client (khi nhận IP tunnel) có thể kết nối qua VPN server.

```sh
vi /etc/ufw/before.rules
```

Thêm Các dòng sau vào trên đầu của file (Phải để ở đầu, bởi vì Iptables thực hiện các lệnh từ trên xuống dưới do đó để tránh 
xảy ra lỗi chúng ta nên đặt ở trên đầu) :

```sh
# START OPENVPN RULES
# NAT table rules
*nat
:POSTROUTING ACCEPT [0:0] 
# Allow traffic from OpenVPN client to eth0
-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE
COMMIT
# END OPENVPN RULES
```

- Enable firewall :

```sh
ufw enable
```

- Chúng ta sẽ nhận được thông báo :

```sh
Command may disrupt existing ssh connections. Proceed with operation (y|n)?
```

- CHọn `Y` để tiếp tục.

- Kiểm tra sự hoạt động của Firewall :

```sh
ufw status
```

###3. Tạo CA và Cert.

- Đầu tiên chúng ta coppy `easy-rsa` vào `/etc/openvpn`

```sh
cp -r /usr/share/easy-rsa/ /etc/openvpn
```

- Tạo một thư mục lưu trữ các key.

```sh
mkdir /etc/openvpn/easy-rsa/keys
```

- Chỉnh sửa các biến trong `easy-rsa`

```sh

# These are the default values for fields
# which will be placed in the certificate.
# Don't leave any of these fields blank.
export KEY_COUNTRY="US"
export KEY_PROVINCE="CA"
export KEY_CITY="hanoi"
export KEY_ORG="datpt"
export KEY_EMAIL="admin@gmail.com"
export KEY_OU="datpt"

# X509 Subject Field
export KEY_NAME="server"

```

- Tạo các thông số Diffie-Hellman:

```sh
openssl dhparam -out /etc/openvpn/dh2048.pem 2048
```

- Di chuyển tới thư mục `/etc/openvpn/easy-rsa` :

```sh
cd /etc/openvpn/easy-rsa
```

- Khởi tạo PKI . Hãy chú ý đến các dấu chấm (.) Và không gian phía trước lệnh ./vars. Điều đó có nghĩa các thư mục làm việc 
hiện tại (nguồn).

```sh
. ./vars
```

- Xóa tất cả các dữ liệu cũ còn lưu lại :

```sh
./clean-all
```

- Tạo CA.

```sh
./build-ca
```

![scr3](http://i.imgur.com/xTIzRP3.png)

- Tạo Cert cho server :

```sh
./build-key-server server
```

![scr4](http://i.imgur.com/QHLcwJs.png)

- Sao chép vào `/etc/openvpn` bởi vì OpenVPN sẽ chỉ thấy key ở trong thư mục này :

```sh
cp /etc/openvpn/easy-rsa/keys/{server.crt,server.key,ca.crt} /etc/openvpn
```

- Khởi bộng dịch vụ `OpenVPN`

```sh
service openvpn start
```

- Tạo Cert cho Client.

```sh
./build-key client1
```

![scr5](http://i.imgur.com/F6gTTy5.png)

- Các tập tin cấu hình cần được sao chép vào mục Easy-RSA. Chúng ta sẽ sử dụng nó như một template mà các client sẽ tải về để 
chỉnh sửa . Trong quá trình sao chép chúng ta thay đổi tập tin từ `client.conf` thành `client.opvn`.

```sh
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/easy-rsa/keys/client.ovpn
```

###4. Tải file cấu hình và test thử trên Client.

- Ở đây sẽ dùng Windows 7 để test , chúng ta cần có [OpenVPN](https://openvpn.net/index.php/open-source/downloads.html) cài đặt 
trên máy client và các file sau từ server :

![scr6](http://i.imgur.com/3UwGYE5.png)

- Các file chúng ta cần tải về đó là :
 <ul>
  <li>client1.crt</li>
  <li>client1.key</li>
  <li>client.ovpn</li>
  <li>ca.crt</li>
 </ul>

- Sau khi đã tải xong chúng ta tiến hành sửa file tại client.

- Chúng ta mở file `client.opvn` bằng notepad++ và sửa như sau:

```sh
# The hostname/IP and port of the server.
# You can have multiple remote entries
# to load balance between the servers.
remote 172.16.1.133 1194 //IP public of VPN server.
```

- Thêm "#" vào các dòng sau :

```sh
ca ca.crt
cert client.crt
key client.key
```

- Thành:

```sh
#ca ca.crt
#cert client.crt
#key client.key
```

- Bỏ dấu ";" ở các dòng sau : 

```sh
;user nobody
;group nogroup
```

- Thành :

```sh
user nobody
group nogroup
```

- Thêm các dòng sau vào cuối file :

```sh
<ca>
//Điền CA vào đây
</ca>
<cert>
//Điền Cert client vào đây
</cert>
<key>
//Điền key client vào đây
</key>
```

- Tiếp theo chúng ta mở 3 file còn lại ra chúng ta sẽ thấy đoạn mã tương tự như sau :

```sh
-----BEGIN CERTIFICATE-----
MIIE8zCCA9ugAwIBAgIBAjANBgkqhkiG9w0BAQsFADCBjjELMAkGA1UEBhMCVVMx
CzAJBgNVBAgTAkNBMQ4wDAYDVQQHEwVoYW5vaTEOMAwGA1UEChMFZGF0cHQxDjAM
BgNVBAsTBWRhdHB0MREwDwYDVQQDEwhkYXRwdCBDQTEPMA0GA1UEKRMGc2VydmVy
MR4wHAYJKoZIhvcNAQkBFg9hZG1pbkBnbWFpbC5jb20wHhcNMTYwOTI5MTIyOTEw
WhcNMjYwOTI3MTIyOTEwWjCBjTELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAkNBMQ4w
DAYDVQQHEwVoYW5vaTEOMAwGA1UEChMFZGF0cHQxDjAMBgNVBAsTBWRhdHB0MRAw
DgYDVQQDEwdjbGllbnQxMQ8wDQYDVQQpEwZzZXJ2ZXIxHjAcBgkqhkiG9w0BCQEW
D2FkbWluQGdtYWlsLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
AMUjcWVRbaXegkO4Lt2TFa8KjalulEktipl1cI+FgMIOepwJ22IF+vzNLUPS//vf
tULQTbSasR7xeBWs1TzQsSNGkrJ0fxpvbkR7VGEgxT1JUVaEc9Xexm8yTLHxzBRQ
Ng4LEga65ElFQ0KoBQ4cnnCZFPg/2YTHngneSypuep8IiXolhCgafclIKSUrymzg
x5xzlFzBByNBWcpmoi2bd60/BpVBbCIfoswxKVBk6I2cU4iHRQwAZSB0IpBMT4XT
6LA2bY1+DiSrvzr7UdnPhwG9jgMq5+EqUM4KX6JtSjUZee68chVPCEay1TIUbnaX
jUwwgtOAAnGAsUiHNbY6XrECAwEAAaOCAVkwggFVMAkGA1UdEwQCMAAwLQYJYIZI
AYb4QgENBCAWHkVhc3ktUlNBIEdlbmVyYXRlZCBDZXJ0aWZpY2F0ZTAdBgNVHQ4E
FgQUWeeGVOYxUvDoV6BavmktvFzTXSowgcMGA1UdIwSBuzCBuIAUNztKh9SaJe6n
+EUKTnZmafHXWnehgZSkgZEwgY4xCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJDQTEO
MAwGA1UEBxMFaGFub2kxDjAMBgNVBAoTBWRhdHB0MQ4wDAYDVQQLEwVkYXRwdDER
MA8GA1UEAxMIZGF0cHQgQ0ExDzANBgNVBCkTBnNlcnZlcjEeMBwGCSqGSIb3DQEJ
ARYPYWRtaW5AZ21haWwuY29tggkA00lkDt78yP4wEwYDVR0lBAwwCgYIKwYBBQUH
AwIwCwYDVR0PBAQDAgeAMBIGA1UdEQQLMAmCB2NsaWVudDEwDQYJKoZIhvcNAQEL
BQADggEBAFEAIvEupikKmDfeW6AL6YZNzlkVGalitAd1pDv5IEPWV8oT5zVI1cNQ
r3C2Is+j8zpQP6iX85TUx899q4rCZLF3URQ3Jz1EBNrzhyf+FFuJ4A+uHFDSUuJV
XEJlBL80+MN73x0gqqnnjzKx1ZG1Jpcxh/vPZ4/Bo+SHJAEePtXR5EdIAA3wRjcU
9FWrwk8xR8kIHWRNaRXilKwTug2pEKxFxRDrSoN4awICYCfoLgD1YSanTZh5zfhH
H6Dhqpx3rfnem0iBI+WbfO5H3cw803QoeBMlPUE+vJM6rSXrS3IL2JBCeJX5ZC0l
JuE5cfWjfqZ4jAI6skUffsRpelaQn+8=
-----END CERTIFICATE-----
```

- CHúng ta chèn từng code tương ứng với chú thích vào đoạn mã chúng ta vừa thêm vào file `client.opvn`.

- Tiếp theo chúng ta coppy các file vừa tải về máy vào đường dẫn `C:\Program Files\OpenVPN\config`

- Sau đó mở `OpenVPN` lên và kết nối thử :

- Kết quả thu được khi thành công :

![scr7](http://i.imgur.com/TOX3QRK.png)

#Nguồn :

https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-14-04