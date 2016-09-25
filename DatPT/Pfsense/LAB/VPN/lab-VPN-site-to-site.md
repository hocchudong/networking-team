#Bài lab thực hiện VPN site-to-site sử dụng IPSEC.

##I. Mô hình thực hiện.

![scr1](http://i.imgur.com/1rPRQXx.png)

- Mô hình thực hiện gồm 2 máy chủ pfSense 2.3.2 . Một máy ở SITE A có IP WAN là 172.16.1.20 và IP LAN là 10.10.10.123
. Máy ở SITE B có IP WAN là 172.16.1.19 và IP LAN là 10.10.20.123.

##II. Thực hiện.

- VPN có 2 hình thức kết nối là `Client to site` và `Site to site` . Với client to site máy client cần phải kết nối đến 
VPN server sau đó client sẽ được cấp phát một địa chỉ VIP để có thể kết nối vào được mạng bên trong. Còn đối với 
site to site chúng ta có thể đồng nhất mạng giữa 2 hoặc nhiều địa điểm lại với nhau mà không sợ lỗi xung đột địa chỉ 
(Ví dụ như ở Site A chúng ta có đại chỉ 10.10.10.10 và Site B cũng thế thì 2 host này vẫn có thể liên lạc được với nhau mà
 không cần phải thay đổi địa chỉ IP).

- Sau đây là bài lab VPN site-to-site sử dụng IPSEC trên pfsense.

**Tại Site A**

- Chúng ta vào phần VPN => IPSEC để bắt đầu thiết lập VPN site-to-site:

![scr1](http://i.imgur.com/eVYoCbo.png)

- Chọn `ADD P1`

![scr2](http://i.imgur.com/UHdkJ5e.png)

- Sau đó thực hiện các thiết lập như hình :

![scr3](http://i.imgur.com/UDibunZ.png)

![scr4](http://i.imgur.com/RMXpqth.png)

- Sau đó `SAVE` lại.

- Sau đó add thêm Phase 2 : 

![scr10](http://i.imgur.com/uqFyL4O.png)

- Thiết lập như hình bên dưới : 

![scr11](http://i.imgur.com/1V3xaEA.png)

![scr13](http://i.imgur.com/XVQKfoG.png)

- Sau đó chúng ta thiết lập `rule` tại SITE A:

![scr5](http://i.imgur.com/JfZEK2K.png)

- Nhấn `ADD` để thêm `rule` mới tại tab WAN :

![scr6](http://i.imgur.com/kPhwKck.png)

- Thiết lập như hình dưới rồi `SAVE` lại :

![scr7](http://i.imgur.com/a0kbjk9.png)

- Tiếp tục thiết lập rule tại mode IPSEC , nhấn vào `ADD` rồi thiết lập như hình dưới :

![scr8](http://i.imgur.com/FWcNgtA.png)

**SITE B**

- Làm giống như SITE A, các địa chỉ của SITE B => SITE A và ngược lại.

- Sau khi thiết lập xong chúng ta `CONNECTION` tại Status => IPSEC.

- Kết quả như hình dưới là chúng ta đã thành công :

![scr12](http://i.imgur.com/WvVFoIx.png)

**Kiểm thử kết nối**

- Ở đây mình sẽ sử dụng một máy client WIN 7 trong LAN SITE A thực hiện PING đến SITE B :

![scr14](http://i.imgur.com/hxU65Ou.png)

##III. Kiểm thử kết quả.

- Ở đây chúng ta sẽ tiến hành kiểm thử kết quả bằng cách PING giữa 2 máy trạm , mỗi máy nằm trong một VPN và dùng Wireshark 
bắt gói tin để kiểm chứng sự đảm bảo của gói tin. Ở đây một máy có địa chỉ IP là `10.10.10.12` và máy kia là `10.10.20.12`

- Sau khi kết nối VPN giữa 2 site với nhau chúng ta tiến hành PING giữa 2 máy trạm với nhau :

![scr7](http://i.imgur.com/HiWu1Zc.png)

- Sau đó dùng Wireshark bắt gói tin trên Card `VMnet8` , chúng ta sẽ thấy được những gói tin có giao thức ESP (của IPsec) 
các gói tin này đã được mã hóa và chúng ta không thể biết bên trong mang gì và hoạt động bên trong là gì.

![scr8](http://i.imgur.com/3weaI87.png)

- Tiếp tục thực hiện trên Card `VMnet1` thì chúng ta có thể thấy được các gói tin đã được mã hóa và đang thực hiện PING với nhau 
được thể hiện qua giao thức ICMP mà chúng ta đã bắt được :

![scr9](http://i.imgur.com/LBkWn7a.png)

```sh
Kết quả kiểm thử cho ta thấy được rằng gói tin khi truyền trên intenet thì sẽ được đảm bảo an toàn và sẽ được giải mã khi đã 
về tới VPN server an toàn.
```

##IV. Các lưu ý khi thực hiện bài lab.

- Vì chúng ta thực hiện trên môi trường lab cho nên chúng ta cần tắt chức năng `Block IP private` ở interface WAN.

![scr10](http://i.imgur.com/SOtlCbh.png)

- Khi kết nối giữa các máy trạm với nhau chúng ta nên tắt firewall của Windows đi.