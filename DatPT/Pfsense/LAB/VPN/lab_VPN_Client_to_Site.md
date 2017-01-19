#Bài lab VPN Client to Site trên pfSense.

**Mục Lục**

[I. Mô hình.] (#mohinh)

[II. Thực hiện.] (#thuchien)

[III. Kết quả kiểm thử. ] (#kiemthu)

[IV. Những lưu ý.] (#luuy)

****

<a name="mohinh"></a>
##I. Mô hình.

![scr24](http://i.imgur.com/SdS68jQ.png)

- Một máy chủ pfSense có cài gói `Open VPN client Export`.
- Một máy client.

<a name="thuchien"></a>
##II. Thực hiện.

- Để thực thiết lập pfSense thành máy chủ VPN chúng ta cần phải cài đặt gói `open vpn client export`

![scr2](http://i.imgur.com/VrBGzf6.png)

- Sau khi cài đặt xong chúng ta bắt đầu tạo chứng chỉ.

```sh
Đối với VPN cần phải lưu ý đến certificate:
 - OpenVPN server đòi hỏi chứng chỉ của các loại : Server.
 - Các Client VPN đòi hỏi một chứng chỉ loại : User
```

- Tạo chứng chỉ như sau :

![scr1](http://i.imgur.com/isnIs4W.png)

- Sau đó tại tab `CAs` chúng ta tạo một CA như sau :

```sh
CA này sẽ giúp chúng ta tạo certificate cho user và server
```

![scr2](http://i.imgur.com/UJ16BTx.png)

```sh
Ở đây ta cần chú ý rằng ở phần METHOD chúng ta chọn mục Create an internal Certificate Authority, các mục khác chúng ta 
thiết lập bình thường.
```

- Sau khi tạo xong CA chúng ta tạo một user cho `VPN` tại `System` => `User manager` :

![scr3](http://i.imgur.com/NpmQTHM.png)

- Tại đây chúng ta tạo một user như sau :

![scr4](http://i.imgur.com/T89oOUc.png)

![scr5](http://i.imgur.com/9rtht58.png)


- Ở đây chúng ta cần phải tạo ra `user` và `password` dùng để xác thực bên phía client. và sau đó chúng ta phải tạo thêm một
`CA for user` - một chứng chỉ cho user sau đó `SAVE` lại.

- Tiếp theo chúng ta thiết lập VPN tại `VPN` => `OpenVPN` :

![scr6](http://i.imgur.com/SLBNAjg.png)

- Chọn tab `Wizards` :

![scr7](http://i.imgur.com/G4El5xs.png)

- Chọn `NEXT`

![scr8](http://i.imgur.com/nIOrlHA.png)

- Chọn `NEXT` tiếp :

![scr9](http://i.imgur.com/8YERx5U.png)


- Chọn `Add new Certificate` - tạo chứng chỉ Server . VPN cần có `CA for user` và `CA for server` trước đó chúng ta
mới tại `CA for user` khi tạo user còn `CA for server` chưa có thì chúng ta phải tạo. 

![scr10](http://i.imgur.com/Jy8bWIg.png)

- Thiết lập như hình sau đó nhấn `Create new Certificate`

![scr11](http://i.imgur.com/BvRbYBX.png)

- Tiếp theo chúng ta đến bước thiết lập connection cho VPN , chúng ta cần thiết lập các thông số như interface, protocol,
local port , tunnel network (tùy ý, đây là sẽ dải mạng mà VPn sẽ cấp phát cho các client khi truy cập vào VPN server).

![scr12](http://i.imgur.com/bYtMwV7.png)

![scr13](http://i.imgur.com/ZsNN9vI.png)

- Sau khi thiết lập xong các thông số chúng ta chọn `NEXT`

- Tiếp theo chúng ta tích vào 2 ô `Firewall rule` và `OpenVPN rule` sau đó chọn `NEXT`

![scr14](http://i.imgur.com/bbG6hZv.png)

- Chọn `Finish` để kết thúc.

![scr15](http://i.imgur.com/MfbglVe.png)

- Sau đó tiến hành export file VPN để dùng tại Client. 

- CHọn tab `VPN` rồi chọn `OpenVPN`

![scr18](http://i.imgur.com/cV4ealY.png)

- Chọn tab `Client export`

![scr19](http://i.imgur.com/XyvUoDJ.png)

- Chọn file phù hợp với phiên bản của hệ điều hành :

![scr20](http://i.imgur.com/bqK1XcS.png)

- Tại Client chúng ta bật `OpenVPN GUI`

![scr21](http://i.imgur.com/B5XiJqc.png)

- Chạy file export vừa tải về :

![scr22](http://i.imgur.com/EhGON3E.png)

- Sau đó connect vào :

![scr23](http://i.imgur.com/pz6lKjz.png)

- Điền user - pass:

![scr24](http://i.imgur.com/TDc8eEq.png)

- Và đây là kết quả thu được :

![scr25](http://i.imgur.com/mcJwFgU.png)

<a name="kiemthu"></a>
##III. Kiểm thử kết quả.

- Ở đây sẽ dùng một máy client kết nối vào VPN với IP là `172.16.1.15` và một máy trạm bên trong mạng VPN có địa chỉ IP là 
`10.10.10.12` Sau đó chúng ta thực hiện PING đến máy trạm bên trong và dùng  Wireshark để thực hiện bắt và phân tích gói tin.

- Sau khi máy client thực hiện kết nối VPN đến VPN server chúng ta tiến hành PING đến máy trạm :

![scr1](http://i.imgur.com/k1PB3id.png)

- Sau đó mở `Wireshark` lên mà tiến hành bắt gói tin trên đường truyền internet để phân tích, cụ thể ở đây là chúng ta cần phải 
bắt gói tin trên card `VMnet8` :

![scr2](http://i.imgur.com/T2LwDKE.png)

- Tại đây chúng ta có thấy các gói tin có giao thức là VPN. Đây là những gói tin mà đã được mã hóa , chúng ta không thể biết được 
giữa máy nguồn và máy đích đang thực hiện trao đổi thông tin gì ,....

![scr3](http://i.imgur.com/oR1m3MD.png)

- Sau đó chúng ta cần bắt gói tin khi đã được giải mã ở tại VPN server , để thực hiện bắt được gói tin này chúng ta cần kết nối 
đến card mạng bên trong VPN server ở đây là `VMnet1`

![scr5](http://i.imgur.com/60mx7Rv.png)

- Ở đây ta có thể thấy được máy nguồn và máy đích đang trao đổi thông tin gì với nhau, cụ thể ở đây là máy nguồn và máy đích
đang thực hiện PING đến nhau, và chúng ta cũng có thể thấy được đâu là gói reply cũng như đâu là gói request.

```sh
Như vậy thông qua kết quả kiểm thử chúng ta đã thấy được rằng gói tin trên đường truyền internet của VPN sẽ được mã hóa và 
người ngoài bắt được cũng không thể nào biết được rằng chúng ta đang thực hiện gì trên đường hầm ảo đó.
```
<a name="luuy"></a>
##IV. Lưu ý khi thực hiện bài lab.

- Vì chúng ta thực hiện trên môi trường lab cho nên chúng ta cần tắt chức năng `Block IP private` ở interface WAN.

![scr10](http://i.imgur.com/SOtlCbh.png)