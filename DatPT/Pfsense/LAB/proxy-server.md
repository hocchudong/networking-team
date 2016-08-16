#Bài lab Proxy server trên pfSense.

****

#Mục lục.

[I. Tổng quan về Proxy server.] (#tongquan)

[II. Chức năng của Proxy server.] (#chucnang)

[III. Lab.] (#lab)
 <ul>
  <li>[1. Dùng proxy server chặn URL] (#chanurl)</li>
 </ul>
****

<a name="tongquan"></a>
##I. Tổng quan về Proxy server.

- Proxy server là một server làm nhiệm vụ chuyển tiếp, kiểm soát thông tin giữa các client (bên truy cập tài nguyên)và
server (cung cấp tài nguyên) . Proxy có một địa chỉ IP và một cổng truy cập cố định.
- Nhờ chức năng chuyển tiếp và kiểm soát, proxy được sử dụng để ngăn chặn kẻ tấn công xâm nhập vào mạng nội bộ và 
proxy cũng là công cụ để xây dựng tường lửa trong hệ thống mạng của các tổ chức có nhu cầu truy cập Internet.
- Cách thức hoạt động : tất cả các yêu cầu từ client gửi đến server trước hết phải qua proxy, proxy kiểm tra xem yêu cầu 
nếu được phép sẽ gửi đến server . Và cũng tương tự khi server gửi phản hồi (respone) lại cho client proxy sẽ kiểm tra và gửi lại 
nếu như phản hồi đó là được phép.

<a name="chucnang"></a>
##II. Chức năng của proxy server.

- Proxy server có 3 chức năng chính đó là :
 <ul>
  <li>Tường lửa và filtering</li>
  <li>Chia sẻ kết nối</li>
  <li>Caching</li>
 </ul>

 ###1. Tường lửa và filtering.

 - Proxy servers làm việc ở lớp Application, lớp 7 trong mộ hình tham chiếu OSI. Chúng không được phổ biến như các tường lửa thông 
 thường mà làm việc ở mức thấp hơn và hỗ trợ lọc ứng dụng một cách độc lập. Proxy servers cũng khó khăn hơn trong việc cài đặt và duy 
 trì so với tường lửa. Mặc dù vậy, nếu proxy server được cấu hình đúng cách sẽ cải thiện được vấn đề bảo mật và hiệu suất cho mạng. 
 Các proxy đều có khả năng mà các tường lửa thông thường không thể cung cấp.
- Một số quản trị viên mạng sử dụng cả tường lửa và proxy server để làm việc cùng nhau. Muốn thực hiện như vậy, họ phải cài đặt cả 
phần mềm tường lửa và phần mềm proxy server trên một server gateway.
- Vì hoạt động lại lớp Application, nên chức năng lọc của proxy servers có thể được coi như một bộ định tuyến thông thường. Cho ví dụ, 
proxy Web server có thể kiểm tra URL của các yêu cầu gửi ra đối với các web page bằng cách thanh tra các thông báo HTTP GET và POST.
 Sử dụng tính năng này, các quản trị viên mạng có thể ngăn chặn sự truy cập và trong miền một cách bất hợp pháp nhưng lại cho phép 
 truy cập vào các site khác. Các tường lửa thông thường, không thể thấy được các tên miền của Web bên trong các thông báo. Với lưu 
 lượng dữ liệu gửi vào, các router thông thường có thể lọc bởi số cổng hoặc địa chỉ mạng, nhưng các proxy server cũng có thể lọc dựa
  trên nội dung ứng dụng bên trong thông báo.

###2. Chia sẻ kết nối.

- Nhiều sản phẩm phần mềm dành cho chia sẻ kết nối trên các mạng gia đình đã xuất hiện trong một số năm gần đây. Mặc dù vậy, trong 
các mạng kích thước lớn và trung bình, proxy server vẫn là giải pháp cung cấp sự mở rộng và hiệu quả trong truy cập Internet. 
Thay cho việc gán cho mỗi máy khách một kết nối Internet trực tiếp thì trong trường hợp này, tất cả các kết nối bên trong đều có thể 
được cho qua một hoặc nhiều proxy và lần lượt kết nối ra ngoài.

###3. Caching.

- Caching của các trang web có thể cải thiện chất lượng dịch vụ của một mạng theo 3 cách. Thứ nhất, nó có thể bảo tồn băng thông mạng, 
tăng khả năng mở rộng. Tiếp đến, có thể cải thiện khả năng đáp trả cho các máy khách. Ví dụ, với một HTTP proxy cache, Web page có 
thể load nhanh hơn trong trình duyệt web. Cuối cùng, các proxy server cache có thể tăng khả năng phục vụ. Các Web page hoặc các dòng 
khác trong cache vẫn còn khả năng truy cập thậm chí nguồn nguyên bản hoặc liên kêt mạng trung gian bị offline.

<a name="lab"></a>
##III. Lab.

<a name="chanurl"></a>
###1. Dùng proxy server chặn URL.

- Đầu tiên chúng ta phải tải package `squid` về để có service Proxy server.

![scr6](http://i.imgur.com/0h6BkHs.png)

- Sau đó chúng ta tìm và tải `squid`

![scr3](http://i.imgur.com/zPE7qyy.png)

- Sau khi quá trình tải về hoàn tất , chúng ta vào phần `service` để tiến hành các thiết lập với proxy server:

![scr7](http://i.imgur.com/xemhmcj.png)

- Tại đây chúng ta chọn phần `Local cache` , kéo xuống cuối và nhấn `SAVE` 

![scr8](http://i.imgur.com/Gk2Ct55.png)

- Tiếp theo chúng ta thiết lập tại phần `General`

![scr9](http://i.imgur.com/SxiC1XU.png)

![scr10](http://i.imgur.com/YV5Adbe.png)

- Sau đó nhấn `SAVE` lại, rồi chọn sang phần `ACls`

![scr11](http://i.imgur.com/gV8vSLZ.png)

- Thêm vào phần `blacklist` những site mà chúng ta cần chặn, ở đây là `google.com.vn` và `facebook.com`

- Test thử trên Client :

![scr4](http://i.imgur.com/v6nlzcH.png)

![scr5](http://i.imgur.com/tR092tx.png)
