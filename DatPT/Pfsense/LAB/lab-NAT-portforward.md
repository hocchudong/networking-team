#Bài lab Port-forward trong pfSense.

##I. Mô hình.

![scr1](http://i.imgur.com/MkPSbr4.png)

- Thực hiện NAT port-forward theo mô hình với một client để test thử kết nối đến địa chỉ chúng ta mốn public website ra ngoài,
một máy chủ pfSense để thực hiện NAT và một máy chủ web-server có card mạng private.

##II. Thực hiện.

- Bước đầu tiên là chúng ta sẽ tạo một vitual IP, đây là địa chỉ mà chúng ta dùng để public website ra ngoài.

![scr2](http://i.imgur.com/Pm5SItO.png)

- Sau đó add thêm một IP mới và thiết lập như sau :

![scr3](http://i.imgur.com/hCXm51d.png)

- `SAVE` lại rồi `Apply change` để tiến hành thay đổi. Sau đó chúng ta thực hiện NAT port forward:

![scr4](http://i.imgur.com/rHsyYC4.png)

- Chọn NAT rồi chọn `ADD` và thiết lập như sau :

![scr5](http://i.imgur.com/gsxAFjf.png)

- Sau đó `SAVE` lại và `Apply change` để lưu lại thiết lập.

- Sau đó chúng ta dùng client để truy cập vào địa chỉ đã NAT với port 80 xem kết quả thế nào :

![scr6](http://i.imgur.com/UsvVDNJ.png)

- Và đây là kết quả khi ta thực hiện ping :

![scr7](http://i.imgur.com/ujB8sL3.png)

- Như thế chúng ta đã thực hiện NAT website public với port 80 . 

##III. Lưu ý:

- Khi thực hiện lab chúng ta cần chú ý loại bỏ 2 check box trong phần `interfaces` => `WAN` như dưới hình :

![scr8](http://i.imgur.com/pYQMm18.png)