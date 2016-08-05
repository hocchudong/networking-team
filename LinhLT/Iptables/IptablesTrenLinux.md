#Tìm hiểu IPtables trong Linux
#Mục lục
**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*
- [1. Giới thiệu - Chức năng](#gioithieuchucnang)
	- [1.1 Giới thiệu](#gioithieu)
	- [1.2 Sự khác biệt trên các distro khác nhau.](#khacbietdistro)
- [2. Các kiến thức cần có](#kienthuc)
	- [2.1 NAT (NetworkAddress Translation)](#nat)
		- [2.1.1 Các kỹ thuật NAT](#kythuatnat)
		- [2.1.2 Cách thức hoạt động của NAT](#natlamviec)
		- [2.1.3 Kỹ thuật masquerade] (#masquerade)
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
Để tránh không làm loãng nội dung, các bạn hãy xem nội dung của phần này trong file `kienthuccanco.md` nằm cùng thư mục với tệp này. :D

#3. Khái niệm - Kiến trúc.

![](http://static.thegeekstuff.com/wp-content/uploads/2011/01/iptables-filter-nat-mangle-tables.png)

Iptables tổ chức phân loại theo cách xử lý gói tin. Các gói tin được xử lý qua các Bảng. Trong mỗi bảng có phân biệt các gói tin đi vào **(INPUT)**, đi ra **(OUTPUT)**, chuyển tiếp **(FORWARD)**, hay cách thức biển đổi địa chỉ đích **(PreRouting)**, biến đổi địa chỉ nguồn **(PostRouting)**, đó chính là các **Chain**. Trong các chain, lại chia thành các **rule**, là danh sách các luật, quy định. **Target/jumps** nói cho rule biết phải làm gì với gói dữ liệu đó (ACCEPT, DROP,...).

##3.1 Tables and Chain
###3.1.1 Mangle table
Bảng này được sử dụng cho modifying packet. Bạn có thể thay đổi trường TOS (Type Of Service) trong gói tin ipdatagram.
Các Targets trong bảng
- TOS: Dùng để thay đổi trường **Type of Service** trong gói tin ipdatagram.
- TTL: Dùng để thay đổi trường **Time To Live** trong gói tin ipdatagram.
- MARK: Dùng để đặt giá trị  **special mark** cho gói tin.

Bạn được khuyên không sử dụng bảng này cho bất kỳ bộ lọc; cũng không có bất kỳ DNAT, SNAT hoặc Masquerading trong bảng này.


###3.1.2 NAT

Bảng này được sử dụng cho chức năng NAT trên các gói tin khác nhau.

`only the first packet in a stream will hit this table. After this, the rest of the packets will automatically have the same action taken on them as the first packet`


DNAT
SNAT
MASQUERADE
REDIRECT


###3.1.3 Filter
Bảng này được sử dụng để lọc gói tin. Chúng ta có thể kết hợp các gói tin và lọc chúng trong bất cứ cách nào chúng ta muốn.

###3.1.4 RAW

Bảng raw chủ yếu chỉ được sử dụng cho một điều, và đó là để thiết lập một đánh dấu trên gói tin rằng họ không nên được xử lý bởi các hệ thống theo dõi kết nối. Điều này được thực hiện bằng target `NOTRACK`.

Bảng này có 2 Chain, đó là
- PREROUTING
- OUTPUT






##3.2 Targets

#4. Packet Flow

#5. Commands

#6. Case trong thực tế.

<a name="thamkhao"></a>
#Tài liệu tham khảo
