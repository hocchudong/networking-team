#Bài lab về service DHCP trong pfSense.

**Mục Lục**

[I. Mô hình.] (#mohinh)

[II. Thực hiện.] (#thuchien)

****

<a name="mohinh"></a>
##I. Mô hình :

![scr8](http://i.imgur.com/dp1bGV5.png)

<a name="thuchien"></a>
##II. Thực hiện.

- Thực hiện cấu hình ở mục `Service` => `DHCP server`

![scr9](http://i.imgur.com/AHMmMyY.png)

- Thực hiện cấu hình các thông số về `range` và `gateway`

- Ở đây chúng ta cũng có thể tạo thêm các pool DHCP khác.

- Sau khi tạo thiết lập xong chúng ta tiến hành `SAVE` lại.

![scr11](http://i.imgur.com/qbz04rU.png)

- Qua máy Client test thử xem máy chủ đã chạy được chưa?

![scr12](http://i.imgur.com/ru3NBcTl.png)