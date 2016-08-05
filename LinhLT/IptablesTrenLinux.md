#Tìm hiểu IPtables trong Linux
#Mục lục
**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*
- [1. Giới thiệu - Chức năng](#gioithieuchucnang)
	- [1.1 Giới thiệu](#gioithieu)
	- [1.2 Sự khác biệt trên các distro khác nhau.](#khacbietdistro)
- [2. Các kiến thức cần có](#kienthuc)
	- [2.1 NAT (NetworkAddress Translation)](#nat)
		- [2.1.1 Các kỹ thuật NAT](#kythuatnat)
	- [2.2 Cấu trúc gói tin IP DATAGRAM](#ipdatagram)
		- [2.2.1 Ý nghĩa các tham số trong IP header:](#ipheader)
		- [2.2.2 Quá trình phân mảnh IP datagram](#phanmanhipdatagram)
- [3. Khái niệm - Kiến trúc.](#)
	- [3.1 Tables](#)
	- [3.2 Chain](#)
	- [3.3 Targets](#)
- [4. Packet Flow](#)
- [5. Commands](#)
- [6. Case trong thực tế.](#)
- [Tài liệu tham khảo](#thamkhao)

<a name="gioithieuchucnang"></a>
#1. Giới thiệu - Chức năng
<a name="gioithieu"></a>
##1.1 Giới thiệu
- Iptables là một tường lửa ứng dụng lọc gói dữ liệu, miễn phí và có sẵn trên Linux.
- Netfilter/Iptables gồm 2 phần là Netfilter ở trong nhân Linux và Iptables nằm ngoài nhân.
- Iptables chịu trách nhiệm giao tiếp giữa người dùng và Netfilter, sau đó đẩy các luật của người dùng vào cho Netfiler xử lí.
- Netfilter tiến hành  lọc các gói dữ liệu ở mức IP.

<a name="khacbiet_distro"></a>
##1.2 Sự khác biệt trên các distro khác nhau.
- Trên CentOS, iptables được mặc định cài đặt với hệ điều hành.
- Trên ubuntu, ufw được mặc định cài đặt với hệ điều hành. Về bản chất, `ufw is a frontend for iptables`. Tức có nghĩa là thay vì gõ lệnh iptables, thì các bạn gõ lệnh ufw. Sau đó, ufw sẽ chuyển các lệnh của ufw sang tập lệnh của iptables. Tất nhiên, iptables sẽ xử lý các quy tắc, chính sách đó. Lệnh ufw là dễ dàng hơn cho những người mới bắt đầu tìm hiểu về firewall. ufw cung cấp framework để quản lý netfilter, và giao diện command-line thân thiện để quản lý firewall.

- Trong bài tìm hiểu này, tôi sẽ trình bày cách sử dụng `iptables` trên môi trường ubuntu14.04. Các bạn chú ý là mình sử dụng trực tiếp `iptables` chứ không phải thông qua `ufw` nữa.

<a name="kienthuc"></a>
#2. Các kiến thức cần có
<a name="nat"></a>
##2.1 NAT (NetworkAddress Translation)
Kỹ thuật NAT dùng để chuyển tiếp các gói tin giữa những lớp mạng khác nhau trên một mạng lớn. NAT dịch hay thay đổi một hoặc cả hai địa chỉ bên trong một gói tin khi gói đó đi qua router, hay một số thiết bị khác.

![](https://anninhmang.net/wp-content/uploads/2014/12/nat1.png)


Ban đầu, NAT được đưa ra nhằm giải quyết vấn đề thiếu hụt địa chỉ IPv4, và sau đó:
- NAT giúp chia sẽ kết nối Internet (hay 1 mạng khác) với nhiều máy trong LAN chỉ với 1 IP duy nhất, hay 1 dãy IP cụ thể.
- NAT che giấu IP bên trong LAN.
- NAT giúp quản trị mạng lọc các gói tin được gửi đến hay gửi từ một địa chỉ IP và cho phép hay cấm truy cập đến một port cụ thể.

<a name="kythuatnat"></a>
###2.1.1 Các kỹ thuật NAT
- **Nat tĩnh (Static NAT)**: là phương thức NAT một đổi một. Nghĩa là một địa chỉ IP cố định trong LAN sẽ được ánh xạ ra một địa chỉ IP Public cố định trước khi gói tin đi ra Internet.
- **Nat động (Dynamic NAT)**: là một giải pháp tiết kiệm IP Public cho NAT tĩnh. Thay vì ánh xạ từng IP cố định trong LAN ra từng IP Public cố định. LAN động cho phép NAT cả dải IP trong LAN ra một dải IP Public cố định ra bên ngoài.
- **NAT Overload – PAT**:  Lúc này mỗi IP trong LAN khi đi ra Internet sẽ được ánh xạ ra một IP Public kết hợp với số hiệu cổng.

<a name="ipdatagram"></a>
##2.2 Cấu trúc gói tin IP DATAGRAM

Giao thức liên mạng IP là cung cấp khả năng kết nối các mạng con thành liên mạng để truyền dữ liệu.
IP là giao thức cung cấp dịch vụ phân phát datagram theo kiểu **không liên kết** và **không tin cậy**
nghĩa là không cần có giai đoạn thiết lập liên kết trước khi truyền dữ liệu,
không đảm bảo rằng IP datagram sẽ tới đích
và không duy trì bất kỳ thông tin nào về những datagram đã gửi đi.

![hình ảnh các thành phần](https://4yatfw.bn1.livefilestore.com/y2pj3_VXtcreN016i6uoHEFSeMQAc6rANxHt3Dkw0cThQkIz15HRRIa3-oyTVkYxkjWWps7EHp3mR-xBoggGUd6XSnt2u-wFruAeBu8_LA0skM/01-%20IP%20header.png)

<a name="ipheader"></a>
###2.2.1 Ý nghĩa các tham số trong IP header:
-	**Version (4 bit):** chỉ phiên bản (version) hiện hành của IP được cài đặt.

-	**IHL: Internet header length (4 bit):** chỉ độ dài phần header tính theo đơn vị từ (word - 32 bit)

-	**Type of Service (8 bit):** đặc tả tham số về yêu cầu dịch vụ: Thông tin về loại dịch vụ và mức ưu tiên của gói IP.

- **Precedence (3 bits):** chỉ thị về quyền ưu tiên gửi datagram, cụ thể là:
```sh
	111 Network control (cao nhất)

	110 Internetwork Control

	101 CRITIC/ECP

	100 Flas Override

	011 flash

	010 Immediate

	001 Priority

	000 Routine (thấp nhất)
```
-	**Total length (16 bit):** chỉ độ dài toàn bộ IP datagram tính theo byte. Dựa vào trường này và trường header length ta tính được vị trí bắt đầu của dữ liệu trong IP datagram.

-	**Indentification (16 bit):** là trường định danh, cùng các tham số khác như địa chỉ nguồn (Source address) và địa chỉ đích (Destination address) để định danh duy nhất cho mỗi datagram được gửi đi bởi 1 trạm. Thông thường phần định danh (Indentification) được tăng thêm 1 khi 1 datagram được gửi đi.
-	**Flags (3 bit):** các cờ, sử dụng trong khi phân đoạn các datagram.

![](https://4yatfw.bn1.livefilestore.com/y2phlastvdF-KwMXVyPrpwowT-ZnQ8XKpoEBONbun1VqRZxk89sye8YrlKDEUYGbp26_XRwDlHFJdVPTD79zHYHdO6sOBawzjAEvIlelqtpnts/02-%20flag.png)


-	**Fragment Offset (13 bit):** chỉ vị trí của đoạn phân mảnh (Fragment) trong datagram tính theo đơn vị 64 bit.

-	**TTL -Time to live  (8 bit):** thiết lập thời gian tồn tại của datagram để tránh tình trạng datagram bị quẩn trên mạng. TTL thường có giá trị 32 hoặc 64 được giảm đi 1 khi dữ liệu đi qua mỗi router. Khi trường này bằng 0 datagram sẽ bị hủy bỏ và sẽ không báo lại cho trạm gửi.

-	**Protocol (8 bit):** chỉ giao thức tầng trên kế tiếp

-	**Header checksum (16 bit):** để kiểm soát lỗi cho vùng IP header.

-	**Source address (32 bit):** địa chỉ IP trạm nguồn

-	**Destination address (32 bit):** địa chỉ IP trạm đích

-	**Option (độ dài thay đổi):** khai báo các tùy chọn do người gửi yêu cầu, thường là:
  - **Độ an toàn và bảo mật:** Bảng ghi tuyến mà datagram đã đi qua được ghi trên đường truyền

    - **Time stamp:** Xác định danh sách địa chỉ IP mà datagram phải qua nhưng datagram không bắt buộc phải truyền qua router định trước

	Xác định tuyến trong đó các router mà IP datagram phải được đi qua

- **Data:** Chứa thông tin lớp trên, chiều dài thay đổi đến 64Kb . Là TCP hay UDP Segment của tầng Transport gửi xuống cho tần Network , tầng  Network sẽ thêm header vào à Gói tin IP datagram .

<a name="phanmanhipdatagram"></a>
###2.2.2 Quá trình phân mảnh IP datagram

![](http://i.imgur.com/Gjdivyl.gif)

Một đặc tính khác mà giao thức IP cho phép đó là sự phân mảnh ( Fragmentation ) . Như chúng ta đã đề cập trước đó , để tới đích , Datagram của IP sẽ có thể qua một vài mạng khác nhau ở giữa của đường đi . Nếu tất cả những mạng trong đường đi giữa máy tính truyền và máy tính nhận là một , thì mọi thứ đều tốt đẹp , bởi vì tất cả Router sẽ làm việc với cùng một cấu trúc ( có nghĩa là có cùng kích thước MTU ) .

Tuy nhiên , nếu những mạng khác không phải là mạng Ethernet , chúng có thể sẽ dùng kích thước MTU khác nhau  . Nếu điều đó xảy ra thì Router mà nhận những Frame có MTU là 1500 Byte sẽ cắt Datagram IP bên trong mỗi Frame thành nhiều mẩu để truyền trên mạng khác có kích thước MTU nhỏ hơn . Nhờ vào việc đến Router mà có đầu ra nối với mạng Ethernet thì Router này sẽ lắp ráp lại Datagram gốc ban đầu .

Ví dụ hình trên, Frame ban đầu dùng MTU có kích thước 1500 Byte . Khi tới mạng khác với MTU có kích thước 620 Byte thì mỗi Frame ban đầu được phân chia thành 03 Frame ( hai có kích thước 620 Byte và một có kích thước 300 Byte ) . Sau đó Router mà là đầu ra của mạng này ( Router 2 ) sẽ lắp ráp lại thành Datagram ban đầu .




#3. Khái niệm - Kiến trúc.
##3.1 Tables
##3.2 Chain
##3.3 Targets

#4. Packet Flow

#5. Commands

#6. Case trong thực tế.

<a name="thamkhao"></a>
#Tài liệu tham khảo
- http://www.hocmangcoban.com/2014/05/nat-la-gi-static-nat-dynamic-nat-nat.html
- Các giao thức tầng IP - Khoa CNTT, Đại học Sư phạm Kỹ thuật Hưng Yên. http://voer.edu.vn/pdf/7f6dc2bd/1
