#Bài lab NAT port forward pfSense.

##I. Mô hình:

![scr7](http://i.imgur.com/Xlw4C9C.png)

##II. Thực hiện.

- Trong bài lab này, chúng ta thực hiện NAT các web từ cổng 80 ra cổng 85.
- Trước tiên ta tạo aliass chứa các web như sau:

![scr2](http://i.imgur.com/Gq24kID.png)

- Rồi `Apply change`

![scr3](http://i.imgur.com/C0km3DM.png)

- Tiếp theo đó chúng ta vào `Firewall` rồi vào `NAT`

- Tại đây chọn `Port forward` rồi add thêm NAT

![scr4](http://i.imgur.com/AQBABG8.png)

- Thiết lập như hình sau :

![scr5](http://i.imgur.com/KXBO8FK.png)
![scr6](http://i.imgur.com/KMVMEdK.png)

- Sau đó nhấn `SAVE` lại.

- Các thông số có thể hiểu như sau:
 <ul>
  <li>`Interface : WAN` : Đây là mạng mà chúng ta thực hiện NAT.</li>
  <li>`Protocol`: Giao thức tùy theo ứng dụng được NAT. Ví dụ là web thì là TCP chẳng hạn.</li>
  <li>`Soure` : Ip sources từ bên ngoài internet mặc định là any-any</li>
  <li>`Destination` : Destination là Ip wan</li>
  <li>`Destination range` : Port dùng để NAT</li>
  <li>`Redirect target IP` : IP là IP mà ta muốn NAT, ở đây để alias `web_services` là nhóm IP sẽ NAT</li>
  <li>`Redirect target port` : Port được NAT ra ngoài</li>
 </ul>

 - OK. Tiếp theo chúng ta phải đi thiết lập rules.

 ![scr7](http://i.imgur.com/6JQME9S.png)

 - Chọn vào NAT mà chúng ta muốn thiết lập rules để edit.

 - Ở đây chúng ta có những lựa trong như sau :

 ![scr8](http://i.imgur.com/436uiX4.png)

- Phần Action chúng ta có 3 lựa chọn:
  <ul>
   <li>Pass : cho phép.</li>
   <li>Reject : Không trả lời lại cho Client.</li>
   <li>Block : Khóa.</li>
  </ul>

![scr9](http://i.imgur.com/Ac5vkxz.png)

- Disable : Nếu chọn phần này rules sẽ không còn tác dụng nữa.
- Interface: Card mạng
- Log : Check vào sẽ bật tính năng ghi log.
- Sau khi thiết lập xong ấn `SAVE` để lưu lại rules.

![scr10](http://i.imgur.com/9RUOKRa.png)