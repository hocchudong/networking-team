#Tổng quan về VPN.

**Mục Lục**

[1. Khái niệm.] (#khainiem)

[2. Phân loại VPN.] (#phanloai)

****

<a name="khainiem"></a>
##1. Khái niệm.

- VPN (Vitual Private Network) hay mạng riêng ảo, là sự mở rộng của mạng riêng thông qua mạng công cộng. VPN được dùng để kết nối 
các văn phòng chi nhánh người dùng lưu động từ xa kết nối về văn phòng chính. 

![scr2](http://i.imgur.com/VCrXTSy.png)

- VPN là công nghệ cung cấp một phương thức giao tiếp an toàn giữa các mạng riêng dựa vào kỹ thuật gọi là `tunneling` để tạo ra một 
mạng riêng trên môi trường internet . Về bản chất , đây là quá trình cài đặt toàn bộ gói tin vào trong một lớp header chứa thông tin 
định tuyến có thể truyền qua mạng trung gian .

- Một phương pháp chung được tìm thấy trong VPN đó là : `Generic Routing Encapsulation` (GRE) . Giao thức mã hóa định tuyến mã hóa 
GRE cung cấp cơ cấu đóng gói giao thức gói tin (Passenger Protocol) để truyền tải trên giao thức truyền tải (Carrier Protocol). 
Nó bao gồm thông tin về loại gói tin đang mã hóa và thông tin kết nối giữa máy chủ và máy khách.

<a name="phanloai"></a>
##2. Phân loại VPN.

- Đối với doanh nghiệp VPN cung cấp các kết nối được triển khai trên hạ tầng mạng công cộng , giải pháp gồm 3 loại chính :
 <ul>
  <li>Remote Access VPN</li>
  <li>Site-to-site VPN</li>
  <li>Extranet VPN</li>
 </ul>

###2.1. Remote Access VPN.

![scr3](http://i.imgur.com/8dAEHiO.jpg)

- Remote access VPN hay còn được gọi là Dial-up riêng ảo (VPDN) là một kết nối người dùng đến LAN , thường là nhu cầu của một 
tổ chức có nhiều nhân viên cần liên hệ với mạng riêng của mình từ rất nhiều địa chỉ ở xa. Ví dụ như công ty cần thiết lập một 
VPN lớn đến một nhà cung cấp dịch vụ doanh nghiệp (ESP). Doanh nghiệp này tạo một con máy chủ truy cập mạng (NAS) và cung cấp 
cho những người sử dụng ở xa một phần mềm máy khách để truy cập vào mạng của công ty . Loại VPN này cho phép các kết nối an toàn 
có mật mã.

**Các thành phần chính**

- Remote Access Server (RAS) : được đặt tại trung tâm có nhiệm vụ xác nhận và chứng nhận các yêu cầu gửi tới.
- Quay số kết nối đến trung tâm, điều này sẽ làm giảm chi phí cho một số yêu cầu ở xa trung tâm.
- Hỗ trợ cho những người có nhiệm vụ cấu hình , bảo trì và quản lý RAS và hỗ trợ truy cập từ xa bởi người dùng.
- Bằng việc sử dụng triển khai Remote Access VPNs, những người dùng từ xa hoặc các chi nhánh văn phòng chỉ cần đặt một kết nối cục 
bộ đến ISP hoặc ISP's POP và kết nối đến tài nguyên thông qua internet.

**Thuận lợi của Remote Access VPN**

- Sự cần thiết hỗ trợ cho người dùng các nhân được loại trừ bởi vì kết nối từ xa đã được tạo điều kiện thuận lợi từ ISP.
- Việc quay số nhanh từ những khoảng cách xa được loại trừ , thay vào đó sẽ là các kết nối cục bộ.
- Giảm giá thành chi phí cho các kết nối với khoảng cách xa.
- VPNs cung cấp khả năng truy cập đến trung tâm tốt hơn bởi vì nó hỗ trợ dịch vụ truy cập ở mức độ tối thiểu nhất cho dù có sự tăng 
nhanh chóng các kết nối đồng thời đến mạng.

**Một số bất lợi của VPNs**

- sự đe dọa về tính an toàn, như bị tấn công bằng từ chối dịch vụ vẫn còn tồn tại.
- Tăng thêm nguy hiểm sự xâm nhập đối với tổ chức trên Extranet
- Do dựa trên Internet nên khi dữ liệu là các loại high-end data thì việc trao đổi diễn ra chậm chạp.
- Quality of Service (QoS) cũng không được đảm bảo thường xuyên.