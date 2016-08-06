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

##III. Các tính năng.

###1. Aliass

- Trong pfSense , firewall không thể một rule gồm nhiều nhóm IP hay một nhóm port. Vì vậy điều ta cần làm là gom nhóm các IP,
Port hay URL thành một alias. Một alias sẽ cho phép thay thế một host , một dải mạng , nhiều IP riêng biệt hay một nhóm port,URL,...
 Alias giúp ta có thể tiết kiệm được phần lớn nếu chúng ta sử dụng một cách chính xác như thay vì sử dụng hàng loạt rule để thiết
 lập cho nhiều địa chỉ , ta chỉ cần sử dụng một rule duy nhất để gom nhóm lại.

###2. NAT.

- Trong pfSense hỗ trợ 4 kiểu NAT đó là :
 <ul>
  <li>NAT 1:1</li>
  <li>NAT Port forward</li>
  <li>NAT outbound (default)</li>
  <li>NAT NTP trong IPv6</li>
 </ul>

- PfSense có hỗ trợ tính năng NAT 1:1 , điều kiện để thực hiện được NAT 1:1 là ta phải có IP public . Khi thực hiện NAT 1:1
thì IP Private được NAT  sẽ luôn ra ngoài bằng IP public tương ứng và các port cũng tương ứng trên IP public.

- PfSense có hỗ trợ NAT outbound mặc định với Automatic outbound NAT rule generation cũng như Port forward ngoài ra còn có NTP
cho IPv6.

###3. Firewall schedules.

- Đây là một tính năng rất hay của pfSense , các firewall rule được sắp xếp để nó chỉ hoạt động ở các thời điểm nhất định trong ngày
hoặc vào những ngày nhất định cụ thể là các ngày trong tuần. Nó thực tế với những nhu cầu của các doanh nghiệp muốn quản lý nhân viên
của mình trong giờ hành chính.

###4. Traffic shaper.

- Đây là tính năng giúp quản trị mạng có thể tinh chỉnh , tối ưu hóa đường truyền trong pfSense . Trong pfSense, một đường truyền 
băng thông sẽ chia ra các hàng khác nhau. Có 7 loại hàng trong pfSense:
 <ul>
  <li>Hàng qACK: dành cho các gói ACK (gói nhận) trong giao thức TCP ở những ứng dụng chính cần được hỗ trợ như HTTP,SMTP,....
  Luồng thông tin ACK tương đối nhỏ nhưng lại rất cần thiết để duy trì tốc độ lưu thông lớn.</li>
  <li>Hàng qVoIP: Dành cho những loại lưu thông cần đảm bảo độ trễ nghiêm ngặt , thường dưới 10ms như VoIP, video conferences</li>
  <li>Hàng qGames: Dành cho những loại thông tin cần đảm bảo độ trễ chặt chẽ thường dưới 50ms như SSH, gameonline,....</li>
  <li>Hàng qOthersHigh: Dành cho các loại ứng dụng có tính quan trọng tương tác rất cao, cần đáp ứng nhanh, cần độ trễ thấp như 
  NTP, DNS, SNMP,....</li>
  <li>Hàng qOthersDefault: Dành cho các giao thức ứng dụng có tính tương tác vừa, cần độ đáp ứng nhất định như HTTP, IMAP,....</li>
  <li>Hàng qOthersLow: Dành cho các giao thức ứng dụng quan trọng có tính tương tác thấp như SMTP, POP3, FTP.</li>
 </ul>

- Mặc định trong pfSense , các hàng sẽ có độ ưu tiên từ thấp đến cao :

```sh
qP2P<qOthersLow<qOthersDefault<qOthersHigh<qGames<qACK<qVoIP
```

- Chúng ta cũng có thể chỉnh lại độ ưu tiên priority cũng như dung lượng băng thông bandwidth mặc định mà các hàng chiếm để nâng cao
băng thông cho các hàng tương ứng.

- PfSense cũng hỗ trợ giới hạn tốc độ Download/Upload của một IP hay một dải IP với ta thiết lập thông số tại phần limiter.
Firewall pfSense hỗ trợ chặn những ứng dụng chạy trên Layer 7-App trong mô hình OSI như sip, ftp, http,....

###5. VPN.

- Một tính năng không thể thiếu đó chính là VPN . PfSense cũng hỗ trợ VPN qua 4 giao thức : IPSEC, L2TP, PPTP, OpenVPN.

###6. Monitor băng thông.

- PfSense có rất nhiều plugin hỗ trợ monitor băng thông . Một số plugin thông dụng như :
 <ul>
  <li>RRD Graphs</li>
  <li>Lightsquid</li>
  <li>BandwidthD</li>
  <li>Ntop</li>
 </ul>
