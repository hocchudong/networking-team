#Kiến thức cần có.

Để hiểu rõ về cách hoạt động iptables và từ đó, áp dụng để viết các rule, thì các bạn phải nắm chắc các phần kiến thức dưới đây.
#Mục lục
**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*

- [1. NAT (NetworkAddress Translation)](#nat)
	- [1.1 Các khái niệm](#khainiemnat)
	- [1.2 Các kỹ thuật NAT](#kythuatnat)
		- [1.2.1 NAT tĩnh (Static NAT)](#nattinh)
		- [1.2.2 Nat động (Dynamic NAT):](#natdong)
		- [1.2.3 NAT Overload – PAT:](#pat)
	- [1.3 Cách thức hoạt động của NAT](#natlamviec)
	- [1.4 Kỹ thuật masquerade](#masquerade)
- [2. Cấu trúc gói tin IP DATAGRAM](#ipdatagram)
	- [2.1 Ý nghĩa các tham số trong IP header:](#ipheader)
	- [2.2 Quá trình phân mảnh IP datagram](#phanmanhipdatagram)
- [3. Tài liệu tham khảo](#thamkhao)


<a name="nat"></a>
#1. NAT (NetworkAddress Translation)

Kỹ thuật NAT dùng để chuyển tiếp các gói tin giữa những lớp mạng khác nhau trên một mạng lớn. NAT dịch hay thay đổi một hoặc cả hai địa chỉ bên trong một gói tin khi gói đó đi qua router, hay một số thiết bị khác.

![](http://s.hswstatic.com/gif/nat-router.jpg)

Ban đầu, NAT được đưa ra nhằm giải quyết vấn đề thiếu hụt địa chỉ IPv4, và sau đó:
- NAT giúp chia sẽ kết nối Internet (hay 1 mạng khác) với nhiều máy trong LAN chỉ với 1 IP duy nhất, hay 1 dãy IP cụ thể.
- NAT che giấu IP bên trong LAN.
- NAT giúp quản trị mạng lọc các gói tin được gửi đến hay gửi từ một địa chỉ IP và cho phép hay cấm truy cập đến một port cụ thể.

<a name="khainiemnat"></a>
##1.1 Các khái niệm

![](https://anninhmang.net/wp-content/uploads/2014/12/nat1.png)

- **Inside local address:** Địa chỉ IP được gán cho một host của mạng trong. (ip private)
- **Inside global address:** Là địa chỉ hợp lệ được cung cấp bởi nhà cung cấp dịch vụ internet. (ip public).
- **Outside local address:** Là địa chỉ IP của host thuộc mạng bên ngoài. (Có thể là ip public hoặc private)
- **Outside global address:** Là địa chỉ IP được gán cho 1 host thuộc mạng ngoài. Các host thuộc mạng bên trong sẽ nhìn thấy host thuộc mạng bên ngoài thông qua địa chỉ này.  (ip public).

<a name="kythuatnat"></a>
##1.2 Các kỹ thuật NAT
<a name="nattinh"></a>
###1.2.1 NAT tĩnh (Static NAT)
Là phương thức NAT một đổi một. Nghĩa là một địa chỉ IP cố định trong LAN sẽ được ánh xạ ra một địa chỉ IP Public cố định trước khi gói tin đi ra Internet.

![](http://www.firewall.cx/images/stories/nat-static-part1-1.gif)

Nhìn vào hình trên ta thấy, mỗi địa chỉ ip private sẽ được NAT cố định sang 1 địa chỉ ip public để có thể nói chuyện được trên internet. Đó là:
```sh
192.168.0.1 -> 203.31.218.208
192.168.0.2 -> 203.31.218.209
192.168.0.3 -> 203.31.218.210
```

- Đường đi của gói tin khi dùng NAT tĩnh

  - Mô hình

    ![](http://www.firewall.cx/images/stories/nat-static-part2-1.gif)

    Máy tính Workstation1 (192.168.0.3) gửi một request đến 1 địa chỉ trên mạng Internet.

  - Gói tin đi ra ngoài

    ![](http://www.firewall.cx/images/stories/nat-static-part2-2.gif)

    Khi đến router, gói tin sẽ được thay đổi địa chỉ nguồn, từ `192.168.0.3 ->203.31.220.135` theo thông tin có trong bảng NAT table của router. Sau đó, gói tin sẽ được gửi đi trên internet.
  - Gói tin từ ngoài đi vào trong

    ![](http://www.firewall.cx/images/stories/nat-static-part2-3.gif)

    Tương tự như thế, khi gói tin từ mạng internet vào đến router, router sẽ thay đổi địa chỉ đích, từ `203.31.220.135 ->192.168.0.3` rồi đi vào máy tính Workstation1.


<a name="natdong"></a>
###1.2.2 Nat động (Dynamic NAT):

Là một giải pháp tiết kiệm IP Public cho NAT tĩnh. Thay vì ánh xạ từng IP cố định trong LAN ra từng IP Public cố định. LAN động cho phép NAT cả dải IP trong LAN ra một dải IP Public cố định ra bên ngoài. Lúc này, địa chỉ IP public sẽ không gán cố định vào bất kỳ IP private nào cả.

![](http://www.firewall.cx/images/stories/nat-dynamic-part1-1.gif)

Ở hình trên, ta thấy:
```sh
192.168.0.1 -> 203.31.218.210
192.168.0.2 -> 203.31.218.211
192.168.0.3 -> 203.31.218.212
```
![](http://www.firewall.cx/images/stories/nat-dynamic-part1-2.gif)

Tuy nhiên, vào thời điểm khác
```sh
192.168.0.1 -> 203.31.218.213 (không còn là 203.31.218.210 nữa)
192.168.0.3 -> 203.31.218.210 (không còn là 203.31.218.212 nữa)
```

=>**ip public không gán cố định vào một ip private nào cả**


<a name="pat"></a>
###1.2.3 NAT Overload – PAT:

Lúc này mỗi IP trong LAN khi đi ra Internet sẽ được ánh xạ ra một IP Public kết hợp với số hiệu cổng.

![](http://www.firewall.cx/images/stories/nat-overload-part2-1.gif)

Ở trong hình trên, Workstation1 gửi một request đến một địa chỉ trên mạng internet. Đồng thời Workstation2 cũng gửi một request khác lên mạng internet. Với kỹ thuật NAT Overload, gói tin của cả 2 máy tính này khi đi ra ngoài đều sử dụng chung 1 địa chỉ IP public, đó là `200.0.0.1`. Và, để phân biệt gói tin nào của Workstation1, gói tin nào của Workstation2 thì chúng ta có thêm 1 số hiệu cổng, đi kèm với gói tin request. Ở đây, port 80 ứng với Workstation1 và port 110 ứng với Workstation2.



<a name="natlamviec"></a>
##1.3 Cách thức hoạt động của NAT

![](http://i274.photobucket.com/albums/jj269/luongkhiem/ipta1.gif)

- NAT Router đảm nhận việc chuyển dãy IP nội bộ 169.168.0.x sang dãy IP mới 203.162.2.x.
- Khi có gói liệu với IP nguồn là 192.168.0.200 đến router, router sẽ đổi IP nguồn thành 203.162.2.200 sau đó mới gửi ra ngoài. Quá trình này gọi là **SNAT** (Source-NAT, NAT nguồn).

![](http://kenhgiaiphap.vn/UserFiles/Image/vyatta2/kenhgiaiphap_vn_10(1).jpg)

- Router lưu dữ liệu trong một bảng gọi là bảng NAT động.
- Ngược lại, khi có một gói từ liệu từ gởi từ ngoài vào với IP đích là 203.162.2.200, router sẽ căn cứ vào bảng NAT động hiện tại để đổi địa chỉ đích 203.162.2.200 thành địa chỉ đích mới là 192.168.0.200. Quá trình này gọi là **DNAT** (Destination-NAT, NAT đích).

![](http://kenhgiaiphap.vn/UserFiles/Image/vyatta2/kenhgiaiphap_vn_11(1).jpg)

- Liên lạc giữa 192.168.0.200 và 203.162.2.200 là hoàn toàn trong suốt (transparent) qua NAT router. NAT router tiến hành chuyển tiếp (forward) gói dữ liệu từ 192.168.0.200 đến 203.162.2.200 và ngược lại.

<a name="masquerade"></a>
##1.4 Kỹ thuật masquerade
- NAT Router chuyển dãy IP nội bộ 192.168.0.x sang một IP duy nhất là 203.162.2.4 bằng cách dùng các số hiệu cổng (port-number) khác nhau.
- Chẳng hạn khi có gói dữ liệu IP với nguồn 192.168.0.168:1204, đích 211.200.51.15:80 đến router, router sẽ đổi nguồn thành 203.162.2.4:26314 và lưu dữ liệu này vào một bảng gọi là bảng masquerade động.
- Khi có một gói dữ liệu từ ngoài vào với nguồn là 221.200.51.15:80, đích 203.162.2.4:26314 đến router, router sẽ căn cứ vào bảng masquerade động hiện tại để đổi đích từ 203.162.2.4:26314 thành 192.168.0.164:1204.
- Liên lạc giữa các máy trong mạng LAN với máy khác bên ngoài hoàn toàn trong suốt qua router.
- **Masquerade thường được dùng trong trường hợp IP thật thay đổi liên tục (ip public).**

![](http://i274.photobucket.com/albums/jj269/luongkhiem/ipta2.gif)

<a name="ipdatagram"></a>
#2. Cấu trúc gói tin IP DATAGRAM

Giao thức liên mạng IP là cung cấp khả năng kết nối các mạng con thành liên mạng để truyền dữ liệu.
IP là giao thức cung cấp dịch vụ phân phát datagram theo kiểu **không liên kết** và **không tin cậy**
nghĩa là không cần có giai đoạn thiết lập liên kết trước khi truyền dữ liệu,
không đảm bảo rằng IP datagram sẽ tới đích
và không duy trì bất kỳ thông tin nào về những datagram đã gửi đi.

![hình ảnh các thành phần](https://4yatfw.bn1.livefilestore.com/y2pj3_VXtcreN016i6uoHEFSeMQAc6rANxHt3Dkw0cThQkIz15HRRIa3-oyTVkYxkjWWps7EHp3mR-xBoggGUd6XSnt2u-wFruAeBu8_LA0skM/01-%20IP%20header.png)

<a name="ipheader"></a>
##2.1 Ý nghĩa các tham số trong IP header:
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
##2.2 Quá trình phân mảnh IP datagram

![](http://i.imgur.com/Gjdivyl.gif)

Một đặc tính khác mà giao thức IP cho phép đó là sự phân mảnh ( Fragmentation ) . Như chúng ta đã đề cập trước đó , để tới đích , Datagram của IP sẽ có thể qua một vài mạng khác nhau ở giữa của đường đi . Nếu tất cả những mạng trong đường đi giữa máy tính truyền và máy tính nhận là một , thì mọi thứ đều tốt đẹp , bởi vì tất cả Router sẽ làm việc với cùng một cấu trúc ( có nghĩa là có cùng kích thước MTU ) .

Tuy nhiên , nếu những mạng khác không phải là mạng Ethernet , chúng có thể sẽ dùng kích thước MTU khác nhau  . Nếu điều đó xảy ra thì Router mà nhận những Frame có MTU là 1500 Byte sẽ cắt Datagram IP bên trong mỗi Frame thành nhiều mẩu để truyền trên mạng khác có kích thước MTU nhỏ hơn . Nhờ vào việc đến Router mà có đầu ra nối với mạng Ethernet thì Router này sẽ lắp ráp lại Datagram gốc ban đầu .

Ví dụ hình trên, Frame ban đầu dùng MTU có kích thước 1500 Byte . Khi tới mạng khác với MTU có kích thước 620 Byte thì mỗi Frame ban đầu được phân chia thành 03 Frame ( hai có kích thước 620 Byte và một có kích thước 300 Byte ) . Sau đó Router mà là đầu ra của mạng này ( Router 2 ) sẽ lắp ráp lại thành Datagram ban đầu .

<a name="thamkhao"></a>
#3. Tài liệu tham khảo
- http://www.hocmangcoban.com/2014/05/nat-la-gi-static-nat-dynamic-nat-nat.html
- http://soaptek.blogspot.com/2012/12/thiet-lap-tuong-lua-iptables-cho-linux.html
- Các giao thức tầng IP - Khoa CNTT, Đại học Sư phạm Kỹ thuật Hưng Yên. http://voer.edu.vn/pdf/7f6dc2bd/1
- http://www.firewall.cx/networking-topics/network-address-translation-nat.html
