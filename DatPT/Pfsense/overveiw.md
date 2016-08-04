#Tổng quan về Pfsense.

#Mục Lục:

##I. Giới thiệu về Pfsense.

- Để bảo vệ cho hệ thống mạng thì người ta có nhiều giải pháp như sử dụng router Cisco, dùng firewall cứng, firewall mềm của Microsoft
như ISA,.... Tuy nhiên những thiết bị trên rất tốn kinh phí vì vậy đối với các doanh nghiệp vừa và nhỏ thì giải phát firewall mã
nguồn mở là một phương án rất hiệu quả. Pfsense là một ứng dụng có chức năng định tuyến và tường lửa mạng và miễn phí trên nền tảng 
FreeBSD có chức năng định tuyến và tường lửa rất mạnh . Pfsense được cấu hình qua giao diện GUI trên nền web nên có thể quản lý một
cách dễ dàng . Nó hỗ trợ lọc địa chỉ theo nguồn hay đích , cũng như port nguồn hay port đích đồng thời hỗ trợ định tuyến và có thể hoạt
động trong chế độ Bridge hay Transparent. Nếu sử dụng Pfsense là gateway, ta cũng có thể thấy rõ việc hỗ trợ NAT và port forward
trên Pfsense cũng như thực hiện cân bằng tải hay failover trên các đường mạng.

- Trong phân khúc tường lửa cho doanh nghiệp vừa và nhỏ , với khoảng 1000 người sử dụng , Pfsense được đánh giá là tường lửa mã nguồn
mở tốt nhất hiện nay với khả năng đáp ứng lên tới hàng triệu khối kết nối đồng thời.

##II. Những đặc điểm nổi trội của Pfsense và những hạn chế.

**Đặc điểm nổi trội**

- Những đặc điểm nổi trội của Pfsense so với các firewall khác :
 <ul>
  <li>Tường lửa Layer 3, L4, L7.</li>
  <li>Chặn truy cập theo khu vực địa lý.</li>
  <li>Quản lý chất lượng QoS.</li>
  <li>Proxy.</li>
  <li>Quản trị mạng không dây.</li>
  <li>Hỗ trợ VLAN.</li>
  <li>Cân bằng tải.</li>
  <li>VPN theo 4 giao thức (IPSEC, L2TP, PPTP, OpenVPN).</li>
  <li>Giám sát/Phân tích mạng.</li>
  <li>Quản lý tên miền (DC) ; hỗ trợ tên miền động (DynDNS).</li>
  <li>Cho phép chạy song hành, failover.</li>
  <li>Tự động cấp nhật blacklist.</li>
 </ul>

- Hoàn toàn miễn phí, giá cả là ưu thế vượt trội của tường lửa pfSense . Tuy nhiên rẻ nhưng không có nghĩa là kém chất lượng ,
tường lửa pfSense hoạt động cực kì ổn định với hiệu năng cao, đã tối ưu hóa cả mã nguồn và hệ điều hành. Cũng chính vì thế , pfSense
không cần nền tảng phần cứng mạnh.

- Nếu doanh nghiệp không có đường truyền tốc độ cao, tường lửa pfSense chỉ cần đặt lên một máy tính cá nhân là có thể bắt đầu hoạt
động . Điều nàng càng làm giảm chi phí triển khai , đồng thời tạo nên sự linh hoạt, tính mở rộng và sẵn sàng chưa từng có, khi 
doanh nghiệp có cần nhiều hơn một tường lửa.

- Không chỉ là một tường lửa, pfSense hoạt động như một thiết bị mạng tổng hợp với đầy đủ mọi tính năng toàn diện sẵn sàng bất
cứ lúc nào. Khi có một vấn đề với hệ thống mạng phát sinh, thay vì phải loay hoay tìm thiết bị và mất thời gian đặt hàng, doanh
nghiệp có thể kết hợp các tính năng đa dạng trên pfSense để tạo thành giải pháp hợp lý , khác phục sự cố ngay lập tức .

- Không kém phần quan trọng đó là khả năng quản lý. Tường lửa pfSense được quản trị một cách dễ dàng , trong sáng qua giao diện web.

![scr1](http://i.imgur.com/Mg3besx.png)

- PfSense là sự kết hợp hoàn hảo và mạnh mẽ, đem lại sự hợp lý cho các nhà tà chính, sự tin tưởng của các nhà quản trị.