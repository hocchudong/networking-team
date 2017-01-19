#Lab gửi report sử dụng Light Squid trên pfSense.

**Mục lục**

[A. Mô hình.] (#mohinh)

[B. Thực hiện.] (#thuchien)

****

<a name=mohinh></a>
##A. Mô hình.

![scr10](http://i.imgur.com/CCMsXuD.png)

- Mô hình thực hiện với máy chủ pfSense (10.10.10.123/24) cùng với một máy Win client (10.10.10.133) thực hiện NAT 1:1 để
có thể truy caahp ra ngoài internet. Trên máy chủ pfSense cài đặt `Lightsquid` để có thể gửi report về các hoạt động của máy
Win client.

<a name=thuchien></a>
##B.Thực hiện.

- Để bắt đầu thực hiện chúng ta phải cài `Lightsquid` cho pfSesne.

- Ở đây đã thực hiện cài đặt thành công package `Lightsquid`

![scr1](http://i.imgur.com/jobphxU.png)

- Vì các report dựa trên file log của proxy , do đó chúng ta phải bật chức năng check log trong proxy server.

![scr2](http://i.imgur.com/I5hkPY9.png)

![scr3](http://i.imgur.com/P3m8lP0.png)

![scr4](http://i.imgur.com/9TlokVm.png)

- Tiếp theo chúng ta thiết lập `Report Proxy` tại mục `Status` như sau:

![scr5](http://i.imgur.com/KR4DuCF.png)

- Ở đây chúng ta có các thiết lập :

![scr6](http://i.imgur.com/sRbvryy.png)

- Thiết lập port , SSL (thiết lập riêng tư) , user và pass chính là user và pass mà chúng ta đăng nhập vào pfSense

![scr7](http://i.imgur.com/eDuHQ3W.png)

- Thiết lập template cho Web GUI , chọn method (cái sẽ report về) , những URL bỏ qua và lập lịch nếu có.

- SAu khi thiết lập xong chúng ta `SAVE` lại và chọn `Refresh` hoặc `Refresh full`. Nếu không nhấn vào 1 trong 2 chức năng này
thì WEB sẽ không chạy được (Do chưa có cập nhật nào về thông tin của các client)

- Để xem các report chúng ta truy cập vào `IP_pfSense:port` để xem thông tin.

![scr8](http://i.imgur.com/bCTaCwr.png)

![scr9](http://i.imgur.com/M1eyi9E.png)