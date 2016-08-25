#LAB back up và restore cấu hình.

```sh
Trong lúc thực hiện các bài lab về pfSense thì hệ thống thường báo về việc restore config của pfSense, lúc này
tôi bắt đầu tìm hiểu xem nó là cái gì và phát hiện ra đây là một chức năng khá là hay
```

#I. Thực hiện backup.

- Để phòng tránh các bản cấu hình bị sửa đổi sau đó muốn quay lại với cấu hình mà chúng ta cảm thấy đã hợp lý trước đây
chúng ta có thể sử dụng chức năng `backup & restore` của pfSesne. Chức năng này cho phép chúng ta backup toàn bộ cấu hình
hệ thống cũng như 1 phần cấu hình dịch vụ.

- Thực hiện bài lab `backup cấu hình DHCP server`

- Đầu tiên chúng ta kiểm tra cấu hình của DHCP server :

![scr1](http://i.imgur.com/Y7M2220.png)

```sh
Ở đây chúng ta có thể thấy range cấu hình là từ 10.10.10.132 đến 10.10.10.245
```

- Bây giờ chúng ta thực hiện tải file cấu hình hiện thời về .

![scr2](http://i.imgur.com/OjICa9p.png)

- Ở đây ô đầu tiên chúng ta có thể chọn là file backup toàn hệ thống hoặc chỉ dịch vụ nào đó:

![scr3](http://i.imgur.com/KX5eunI.png)

- Sau đó `Download` về : 

![scr4](http://i.imgur.com/TN2bpcL.png)

- Thay đổi file cấu hình DHCP:

![scr5](http://i.imgur.com/JbcuLoN.png)

- Sau đó thực hiện backup lại file cấu hình:

![scr2](http://i.imgur.com/OjICa9p.png)

- Từ đây chọn dịch vụ mà chúng ta cần backup, có thể là cả hệ thống cùng với file cấu hình đã tải trước đó và thực hiện backup:

![scr6](http://i.imgur.com/mLeq90X.png)

- Sau đó kiểm tra lại file cấu hình :

![scr7](http://i.imgur.com/vQxgUEh.png)

