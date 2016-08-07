#Tìm hiểu IPtables trong Linux
#Mục lục
**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*
- [1. Giới thiệu - Chức năng](#gioithieuchucnang)
	- [1.1 Giới thiệu](#gioithieu)
	- [1.2 Sự khác biệt trên các distro khác nhau.](#khacbietdistro)
- [2. Các kiến thức cần có](#kienthuc)
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

###1.2.1 So sánh iptables trên ubuntu và centos

| Đặc điểm |CentOS|ubuntu|
|:----:|:---:|:----:|
|Thư mục cấu hình|/etc/sysconfig/iptables-config|/etc/iptables/|


<a name="kienthuc"></a>
#2. Các kiến thức cần có
Để tránh không làm loãng nội dung, các bạn hãy xem nội dung của phần này trong file `kienthuccanco.md` nằm cùng thư mục với file này. :D

#3. Khái niệm - Kiến trúc.

![](http://static.thegeekstuff.com/wp-content/uploads/2011/01/iptables-filter-nat-mangle-tables.png)

Iptables tổ chức phân loại theo cách xử lý gói tin. Các gói tin được xử lý qua các Bảng. Trong mỗi bảng có phân biệt các gói tin đi vào **(INPUT)**, đi ra **(OUTPUT)**, chuyển tiếp **(FORWARD)**, hay cách thức biển đổi địa chỉ đích **(PreRouting)**, biến đổi địa chỉ nguồn **(PostRouting)**, đó chính là các **Chain**. Trong các chain, lại chia thành các **rule**, là danh sách các luật, quy định. **Target/jumps** nói cho rule biết phải làm gì với gói dữ liệu đó (ACCEPT, DROP,...).

##3.1 Tables
###3.1.1 Mangle table
Bảng này được sử dụng cho modifying packet. Bạn có thể thay đổi trường TOS (Type Of Service) trong gói tin ipdatagram.

Các Targets trong bảng
- TOS: Dùng để thay đổi trường **Type of Service** trong gói tin ipdatagram.
- TTL: Dùng để thay đổi trường **Time To Live** trong gói tin ipdatagram.
- MARK: Dùng để đặt giá trị  **special mark** cho gói tin.

Bạn được khuyên không sử dụng bảng này cho bất kỳ bộ lọc; cũng không có bất kỳ DNAT, SNAT hoặc Masquerading trong bảng này.

Các chain có trong bảng này:
- PREROUTING
- INPUT
- FORWARD
- OUTPUT
- POSTROUTING


###3.1.2 NAT

- Bảng này được sử dụng cho chức năng NAT trên các gói tin khác nhau. Trong một số trường hợp, nó được sử dụng để dịch các trường địa chỉ nguồn và địa chỉ đích của gói tin.

- Chỉ phần đầu của gói tin sẽ được xử lý bởi table. Sau đó, phần còn lại của gói tin sẽ tự động được xử lý như phần đầu của gói tin

- Các target có trong bảng này:
	- DNAT
	- SNAT
	- MASQUERADE
	- REDIRECT

- Các Chain có trong bảng này
	- PREROUTING
	- INPUT
	- OUTPUT
	- POSTROUTING

###3.1.3 Filter

Bảng này được sử dụng để lọc gói tin. Chúng ta có thể kết hợp các gói tin và lọc chúng trong bất cứ cách nào chúng ta muốn.

Các Chain có trong bảng này:
- INPUT
- FORWARD
- OUTPUT

###3.1.4 RAW

Bảng raw chủ yếu chỉ được sử dụng cho một điều, và đó là để thiết lập một đánh dấu trên gói tin rằng họ không nên được xử lý bởi các hệ thống theo dõi kết nối. Điều này được thực hiện bằng target `NOTRACK`.

Bảng này có 2 Chain, đó là
- PREROUTING
- OUTPUT


##3.2 Chain

Mỗi rule mà bạn tạo ra phải tương ứng với một chain, table nào đấy. Nếu bạn không xác định tables nào thì iptables coi mặc định là cho bảng FILTER.

| Chain |Ý nghĩa|
|:----:|:---:|
|INPUT|những gói tin đi vào hệ thống|
|OUTPUT|những gói tin đi ra từ hệ thống|
|FORWARD|những gói tin đi qua hệ thống (đi vào một hệ thống khác|
|PREROUTING| sửa địa chỉ đích của gói tin trước khi nó được routing bởi bảng routing của hệ thống (destination NAT hay DNAT).|
|POSTROUTING|ngược lại với Pre-routing, nó sửa địa chỉ nguồn của gói tin sau khi gói tin đã được routing bởi hệ thống (SNAT).|

##3.3 Targets

| Targets |Mean|Ý nghĩa|
|:----:|:---:|:---:|
|ACCEPT|Accepts the packet.|iptables chấp nhận gói tin, đưa nó qua hệ thống mà không tiếp tục kiểm tra nó nữa|
|DROP|Drops the packet into a black hole. This is one of the most used targets.|iptables loại bỏ gói tin, không tiếp tục xử lý nó nữa|
| QUEUE|Pass the packet to userspace|Chuyển gói tin đến userspace|
|LOG|This option adds a ‘LOG’ target, which allows you to create rules in any iptables table which records the packet header to the syslog|thông tin của gói tin sẽ được ghi lại bởi syslog hệ thống, iptables tiếp tục xử lý gói tin bằng những rules tiếp theo.|
|ULOG|The packet is passed to a userspace logging daemon using netlink multicast sockets; unlike the LOG target which can only be viewed through syslog.|Gói tin sẽ chuyển đến userspace logging daemon sử dụng netlink multicast sockets. Không giống với `LOG`, chỉ được xem bởi `syslog`|
|REJECT|The REJECT target allows a filtering rule to specify that an ICMP error should be issued in response to an incoming packet, rather than silently being dropped|Chức năng của nó cũng giống như DROP tuy nhiên nó sẽ gửi một ICMP error tới host đã gửi gói tin.|
|MASQUERADE|Masquerading is a special case of NAT: all outgoing connections are changed to seem to come from a particular interface’s address, and if the interface goes down, those connections are lost. This is only useful for dialup accounts with dynamic IP address (ie. your IP address will be different on next dialup).|cũng là một kiểu dùng để sửa địa chỉ nguồn của gói tin, chi tiết mọi người có thể nắm rõ hơn trong file `kienthuccanco.md` nằm cùng thư mục này|
|DNAT|Destination NAT which changes the destination address of a packet. Suppose your Apache web server is behind a firewall on a private network. You only have one real IP address and all of your other boxes are on a private network.|dùng để sửa lại địa chỉ đích của gói tin.
|SNAT|Source NAT which changes the source IP address to a real IP address. This is useful for private networks access the Internet.|dùng để sửa lại địa chỉ nguồn của gói tin
|REDIRECT| is a special case of NAT: all incoming connections are mapped onto the incoming interface’s address, causing the packets to come to the local machine instead of passing through. This is useful for transparent proxies.|Là một trường hợp đặc biệt của NAT: Tất cả các kết nối đi vào được mapped với một địa chỉ interface, gây nên gói tin đến máy local thay vì đi qua. Hữu ích cho transparent proxies.|
|NETMAP|NETMAP is an implementation of static 1:1 NAT mapping of network addresses. It maps the network address part, while keeping the host address part intact. It is similar to Fast NAT, except that Netfilter’s connection tracking doesn’t work well with Fast NAT.| NETMAP là một thể hiện của NAT tĩnh. Nó maps gần địa chỉ mạng, giữ lại phần địa chỉ host address. Nó tương tự như Fast NAT, ngoại trừ việc theo dõi kết nối Netfilter không hoạt động cũng với Fast NAT.
|SAME|This option adds a ‘SAME’ target, which works like the standard SNAT target, but attempts to give clients the same IP for all connections.| Tương tự với SNAT, nhưng cố gắng cung cấp cho clients cùng 1 ip cho tất cả kết nối.
|TOS|This option adds a ‘TOS’ target, which allows you to create rules in the ‘mangle’ table which alter the Type Of Service field of an IP packet prior to routing.| Cho phép bạn tạo rules trong bảng Mangle để thay đổi  trường Type Of Service trong gói tin IP.
|ECN|This option adds a ‘ECN’ target, which can be used in the iptables mangle table.You can use this target to remove the ECN bits from the IPv4 header of an IPpacket. This is particularly useful, if you need to work around existing ECN blackholes on the internet, but don’t want to disable ECN support in general.| Được sử dụng trong bảng Mangle. Dùng để xóa đi ECN bits trong header của gói tin IPv4. |
|DSCP|This option adds a ‘DSCP’ match, which allows you to match against the IPv4 header DSCP field (DSCP codepoint). The DSCP codepoint can have any value between 0x0 and 0x4f.| Cho phép bạn đặt lệnh phù hợp với trường DSCP trong gói tin ipv4
|MARK|This option adds a ’MARK’ target, which allows you to create rules in the ’mangle’ table which alter the netfilter mark (nfmark) field associated with the packet prior to routing. This can change the routing method (see ‘Use netfilter MARK value as routing key’) and can also be used by other subsystems to change their behavior.| Dùng trong bảng Mangle. Để thay đổi trường netfilter mark kết hợp với các gói tin trước khi định tuyến. Có thể thay đổi phương thức định tuyến và được sử dụng bởi hệ thông con khác để thay đổi hành động của nó.
|CLASSIFY|This option adds a ’CLASSIFY’ target, which enables the user to set the priority of a packet. Some qdiscs can use this value for classification, among these are: atm, cbq, dsmark, pfifo fast, htb, prio| Cho phép người dùng đặt ưu tiên của các gói tin.
|TCPMSS|CPMSS This option adds a ’TCPMSS’ target, which allows you to alter the MSS value of TCP SYN packets, to control the maximum size for that connection (usually limiting it to your outgoing interface’s MTU minus 40).This is used to overcome criminally braindead ISPs or servers which block ICMP Fragmentation Needed packets. The symptoms of this problem are that everything works fine from your Linux firewall/router, but machines behind it can never exchange large packets: 1) Web browsers connect, then hang with no data received. 2) Small mail works fine, but large emails hang. 3) ssh works fine, but scp hangs after initial handshaking.| Cho phép bạn thay đổi giá trị MSS của gói tin SYN TCP, để điều khiển kích thước tối đa của kết nối.|


#4. Packet Flow

#5. Commands

#6. Case trong thực tế.

<a name="thamkhao"></a>
#Tài liệu tham khảo
