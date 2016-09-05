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

![scr3](http://i.imgur.com/6ae4nUC.png)

- Sau đó nhấn `ADD` rồi điền các thiết lập:

![scr4](http://i.imgur.com/Rs8JeKc.png)

- Sau khi thiết lập xong chứng chỉ chúng ta tạo một user để chúng ta có thể đăng nhập khi sử dụng máy chủ pfSense là máy chủ
OpenVPN:

![scr5](http://i.imgur.com/oWI7tlT.png)

- Chọn `ADD` để thêm user mới , sau đó thiết lập như sau:

![scr6](http://i.imgur.com/NaJADxv.png)

- Chọn vào ô `Click to create a user certificate`

![scr7](http://i.imgur.com/43Lh3Nb.png)

- Đặt tên cũng như chọn vào chứng chỉ mà chúng ta vừa mới tạo trước đó. Sau đó `SAVE` lại.

![scr8](http://i.imgur.com/VJT4hxt.png)

- Tiếp theo chúng ta vào `OpenVPN` để tiến hành các thiết lập cho máy chủ OpenVPN:

![scr9](http://i.imgur.com/sVz4BpG.png)

- Chọn phần `Wizard` : 

![scr10](http://i.imgur.com/Kjwxlve.png)

- Chọn `NEXT`

![scr11](http://i.imgur.com/AqT7T62.png)

- `NEXT` tiếp :

![scr12](http://i.imgur.com/ywNHx4c.png)

- Sau đó chọn `Add new certificate`

![scr13](http://i.imgur.com/8MXVyXX.png)

```sh
Nếu phần này không tạo mới chúng ta sẽ gặp lỗi khi kết nối , lý do :

 This error is created the wrong type of Certificate for the OpenVPN Server.
 The OpenVPN Server requires a certificate of the type:Server
 The OpenVPN Client requires a certificate of the type:User
 Both certificates must use the same Certificate of Authority for their creation
```

- Điền tên sau đó `Create new certificate` lại :

![scr14](http://i.imgur.com/uT9DhJ9.png)

- Tiếp theo đó thiết lập `Port` rồi `NEXT`

![scr15](http://i.imgur.com/sYcAyCg.png)

- Sau đó `NEXT` tiếp:

![scr16](http://i.imgur.com/wATbEEO.png)

- Và `Finish` :

![scr17](http://i.imgur.com/Tgoi1Vo.png)

- Sau đó để lấy được file VPN cho máy client sử dụng ta chon phần `Client export`

![scr18](http://i.imgur.com/Pa4aOp4.png)

- Tùy theo phiên bản client mà chúng ta tải về file cần thiết. 

![scr19](http://i.imgur.com/22iVSyf.png)

- Bật OpenVPN trên máy client :

![scr20](http://i.imgur.com/SrfY9uC.png)

- Chạy file mà chúng ta vừa tải về cho client:

![scr21](http://i.imgur.com/cpkZASq.png)

- Connect từ CLient vào :

![scr22](http://i.imgur.com/9Se7AyC.png)

![scr23](http://i.imgur.com/OO2EUvp.png)

![scr1](http://i.imgur.com/A4zr4Wz.png)


