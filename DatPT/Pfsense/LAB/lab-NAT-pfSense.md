#Bài lab NAT 1:1 trên pfSense.

****

##Mục Lục:

[I.Mô hình] (#mohinh)

[II. Thực hiện] (#thuchien)

[III. Chú ý] (#chuy)

****

<a name="mohinh"></a>

##I. Mô hình thực hiện.

![scr2](http://i.imgur.com/DIiko5Z.png)

- Thiết lập mô hình bao gồm :
 <ul>
  <li>2 máy client (windown và ubuntu server)</li>
  <li>Một máy chủ triển khai pfSense 2.3.2</li>
  <li>2 card mạng (1 card host only và một card NAT nối với máy chủ pfSense)</li>
 </ul>

<a name="thuchien"></a>

##II. Thực hiện.

- Tiến hành tạo ra `Vitual IPs` để chúng ta có thể sử dụng vitual IP này NAT ra bên ngoài.

![scr3](http://i.imgur.com/jmGvmCgl.png)

- Chọn `ADD` để thêm một địa chỉ IP mới :

![scr6](http://i.imgur.com/Qw4Rli7l.png)

- Sau đó thêm một IP mới như sau :

![scr7](http://i.imgur.com/aPeMByDl.png)

```sh
Ở đây chọn Aliasses bởi vì Aliass có chức năng NAT. 
Xem thêm các tính năng của các Vitual IP khác ở [đây](https://doc.pfsense.org/index.php/What_are_Virtual_IP_Addresses) 
```

- `Save` lại và `Apply change`

- Tiếp theo chúng ta thực hiện thiết lập NAT 1:1

![scr8](http://i.imgur.com/9S1mRULl.png)

- Chọn sang mục `NAT 1:1` rồi sau đó thêm mới.

![scr9](http://i.imgur.com/SWPNUqRl.png)

- Thiết lập như sau :
 <ul>
  <li>Interface: CHọn WAN</li>
  <li>External subnet IP : là địa chỉ vitual IP chúng ta đã tạo dùng để thực hiện NAT.</li>
  <li>Internal IP : Là địa chỉ IP của client mà chúng ta muốn NAT.</li>
  <li>`SAVE` lại và `Apply change` để chấp nhận sự thay đổi.</li>
 </ul>

![scr10](http://i.imgur.com/CEkCJALl.png)

- Thiết lập rules:

![scr11](http://i.imgur.com/x02NJ2wl.png)

- Vào mục `rules` ấn vào `ADD` để thêm một rules rồi thiết lập như sau:
 <ul>
  <li>Action : Pass</li>
  <li>Destination : Là địa chỉ mà chúng ta thực hiện NAT</li>
  <li>Sau đó thực hiện `SAVE` lại và `Apply Change`</li>
 </ul>

![scr12](http://i.imgur.com/Goil6OBl.png)

```sh
Vì pfSense đóng vai trò là `Gateway` do đó chúng ta cần đặt lại địa chỉ Gateway cho các client 
là địa chỉ hostonly của pfSense.
```

- Thực hiện đặt lại địa chỉ `Gateway` cho các client.

![scr4](http://i.imgur.com/t4U32fol.png)

![sc13](http://i.imgur.com/vnkgXVdl.png)

- Kiểm tra xem chúng ta đã NAT thành công chưa:

![scr5](http://i.imgur.com/T4N7rEJl.png)

![scr14](http://i.imgur.com/biNkR9fl.png)

![scr15](http://i.imgur.com/FOAxXM3l.png)

![scr16](http://i.imgur.com/7tRqx5hl.png)

<a name="chuy"></a>

##III. Chú ý.

- Trước khi làm bài lab thì phải kiểm tra xem các WAN, LAN đã có `Gateway` hay chưa, nếu chưa có thì chúng ta
kiểm tra lại trước khi lab.

![scr17](http://i.imgur.com/yr5mTJgl.png)

- PfSense đóng vai trò định tuyến vì thế các client phải trỏ `Gateway` về IP của pfSense server.