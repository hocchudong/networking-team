#Monitor hệ thống mạng kết hợp giữa Ntop và Squid Report.

##A. Mô hình triển khai.

![scr14](http://i.imgur.com/tssDZCO.png)

- Mô hình thực hiện gồm  máy chủ pfSense với 2 card mạng, 1 card NAT ra internet và 1 Card trong LAN `10.10.10.0/24` , và 2 client
ubuntu server (10.10.10.132/24) , win-client (10.10.10.133/24) Cả 2 máy đều NAT chung ra một VIP.

##B. Thực hiện.

- Đầu tiên chúng ta tiến hành tải và cấu hình `Squid report` như [sau](https://github.com/hocchudong/networking-team/blob/master/DatPT/Pfsense/LAB/Lab_repor_lightsquid.md)

- Tải và cấu hình `Ntop`

![scr8](http://i.imgur.com/OpqLQfd.png)

- Sau khi tiến hành tải xong `Ntop` chúng ta thực hiện cấu hình dịch vụ `Ntop` như sau:

![scr9](http://i.imgur.com/G19mm3Q.png)

- Enable ntop và thực hiện cho theo dõi trên 2 cổng `LAN` và `WAN` thiết lập password để khi chúng ta đăng nhập vào WEB
mặc định là `pfsense`

![scr10](http://i.imgur.com/0HIdt4e.png)

- Thực hiện truy cập vào WEB để kiểm tra :

![scr11](http://i.imgur.com/k0cjrGA.png)

![scr12](http://i.imgur.com/pAH5Jmt.png)

- Tiếp theo chúng ta dùng máy win-client tải 1 file bất kỳ nào đó nặng 1 chút:

![scr1](http://i.imgur.com/xTOeqOR.png)

- đây là giao diên `Ntop` lúc chưa download :

![scr2](http://i.imgur.com/ZrGN9YJ.png)

- Còn đây là giao diện `Ntop` lúc chúng ta thực hiện download:

![scr3](http://i.imgur.com/0T6MrQX.png)

- CHúng ta có thể thấy lượng lưu thông đã tăng lên , đây là mới đầu nên hơi yếu . Chúng ta thực hiện truy cập vào `Flow`
để xem chi tiết các dòng lưu lượng:

![scr4](http://i.imgur.com/NfgTxpK.png)

- Ở đây chúng ta có thể thấy dòng lưu lượng hiện đang lưu thông hiện tại của server `dowloaf.thicnk...`

- Bây giờ chúng ta vào trang web của `Squid report` qua địa chỉ `Your_ip:7445` để xem thông số về các host :

![scr5](http://i.imgur.com/eKLH58A.png)

- Ở ngày hôm nay chúng ta thấy 1 Oversize.

![scr6](http://i.imgur.com/IyVfLTt.png)

- Host có lưu lượng chiến dụng lớn nhất là `10.10.10.133`

![scr7](http://i.imgur.com/TkMaY4V.png)

- Và địa chỉ hiện tại đang có lượng trao đổi lưu lượng lớn nhất với host này là `download.thicnk....` 

- Từ đây sẽ cho chúng ta biết được host nào đã sử dụng lượng băng thông lớn trong mạng cũng như địa chỉ nguồn mà host này hay truy 
cập đến nhất để có những giải pháp hay những xử lý cho hệ thống mạng .