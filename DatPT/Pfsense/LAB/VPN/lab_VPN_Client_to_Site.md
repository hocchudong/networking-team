#Bài lab VPN Client to Site trên pfSense.

##A. Mô hình.

![scr24](http://i.imgur.com/SdS68jQ.png)

- Một máy chủ pfSense có cài gói `Open VPN client Export`.
- Một máy client.

##B. Thực hiện.

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

- Sau đó tại tab `CAs` chúng ta tạo một Certificate như sau :

![scr2](http://i.imgur.com/UJ16BTx.png)

```sh
Ở đây ta cần chú ý rằng ở phần METHOD chúng ta chọn mục Create an internal Certificate Authority, các mục khác chúng ta 
thiết lập bình thường.
```

- Sau khi tạo xong Certificate chúng ta tạo một user cho `VPN` tại `System` => `User manager` :

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
local port  (Cần chú ý để lúc sau chúng ta cần NAT port này), tunnel network (tùy ý, đây là sẽ dải mạng mà VPn sẽ cấp phát cho các client khi truy cập vào VPN server).

![scr12](http://i.imgur.com/bYtMwV7.png)

![scr13](http://i.imgur.com/ZsNN9vI.png)

- Sau khi thiết lập xong các thông số chúng ta chọn `NEXT`

- Tiếp theo chúng ta tích vào 2 ô `Firewall rule` và `OpenVPN rule` sau đó chọn `NEXT`

![scr14](http://i.imgur.com/bbG6hZv.png)

- Chọn `Finish` để kết thúc.

![scr15](http://i.imgur.com/MfbglVe.png)

- Vì `pfSense` là `Firewall` do đó các port từ server `pfSense` sẽ bị chặn , do đó để client có thể kết nối được với 
VPN server chúng ta còn phải mở port OpenVPN mà chúng ta đã cấp , cụ thể ở đây là port `1194`. Để mở port `1194` hay các
port khác tương tự chúng ta vào tab `Firewall` chọn `NAT`

![scr16](http://i.imgur.com/OOx0D86.png)

- Tại tab `Port Forward` chúng ta chọn `ADD` để thêm mới rồi thiết lập các tùy chọn như sau:

![scr17](http://i.imgur.com/j8hpnwY.png)

- Redirect target IP : là địa chỉ của pfSense server.
- Port  : Chọn OpenVPN.
- protocol : TCP/UDP.

- `SAVE` lại và sau đó tiến hành export file VPN để dùng tại Client. 

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