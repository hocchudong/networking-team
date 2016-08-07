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
![](http://www.linuxhomenetworking.com/wiki/images/f/f0/Iptables.gif)

Đầu tiên gói tin từ mạng A đi vào hệ thống firewall sẽ phải đi qua bảng Mangle với chain là PREROUTING (với mục đích để thay đôi một số thông tin của gói tin trước khi đưa qua quyết định dẫn đường) sau đó gói tin đến bảng NAT với với chain PREROUTING tại đây địa chỉ đích của gói tin có thể bị thay đổi hoặc không, qua bộ routing và sẽ quyết định xem gói tin đó thuộc firewall hay không:

- **TH1: gói tin đó là của firewall:** gói tin sẽ đi qua bảng mangle và đến bản filter với chai là INPUT. Tại đây gói tin sẽ được áp dụng chính sách (rule) và ứng với mỗi rule cụ thể sẽ được áp dụng với target, sau quá trình xử lý gói tin sẽ đi đến bảng mangle tiếp đến là bảng NAT với chain OUTPUT được áp dụng một số chính sách và sau đó đi lần lượt qua các bảng magle với chain POSTROUTING cuối cùng đi đến bảng NAT với chain POSTROUTING để thay đổi địa chỉ nguồn nếu cần thiết.

- **TH2: gói tin không phải của firewall** sẽ được đưa đến bảng mangle với chain FORWARD đến bảng filter với chain FORWARD. Đây là chain được sử dụng rất nhiều để bảo vệ người sử dụng mang trong lan với người sử dụng internet các gói tin thoải mãn các rule đặt ra mới có thể được chuyển qua giữa các card mạng với nhau, qua đó có nhiệm vụ thực hiện chính sách với người sử dụng nội bộ nhưng không cho vào internet, giới hạn thời gian,...và bảo vệ hệ thống máy chủ đối với người dung internet bên ngoài chống các kiểu tấn công. sau khi đi qua card mạng với nhau gói tin phải đi lần lượt qua bảng mangle và NAT với chain POSTROUTING để thực hiên việc chuyển đổi địa chỉ nguồn với target SNAT & MASQUERADE.


#5. Commands
##5.1 COMMANDS

|Commands|Meaning|Ý nghĩa|
|:---:|:---:|:---:|
|**-t, --table** *table*| This option specifies the packet matching table which the command should operate on.| Chỉ ra tên của bảng mà rule của bạn sẽ dược ghi vào (mặc định là FILTER ).|
|**-A, --append** *chain rule-specification*| Append one or more rules to the end of the selected chain. When the source and/or destination names resolve to more than one address, a rule will be added for each possible address combination.| ghi nối tiếp rule vào một chain|
|**-D, --delete** *chain rule-specification*, *chain rulenum*| Delete one or more rules from the selected chain. There are two versions of this command: the rule can be specified as a number in the chain (starting at 1 for the first rule) or a rule to match.| Xóa một hoặc một vài rule trong chain|
|**-I, --insert** *chain [rulenum] rule-specification*| Insert one or more rules in the selected chain as the given rule number. So, if the rule number is 1, the rule or rules are inserted at the head of the chain. This is also the default if no rule number is specified.| Chèn rule vào chain được chọn.|
|**-R, --replace** *chain rulenum rule-specification*|Replace a rule in the selected chain. If the source and/or destination names resolve to multiple addresses, the command will fail. Rules are numbered starting at 1.| Thay thế một rule trên chain được chọn|
| **-L, --list** *[chain]*| List all rules in the selected chain. If no chain is selected, all chains are listed. As every other iptables command, it applies to the specified table (filter is the default), so NAT rules get listed by| Liệt kê tất cả các rule trong chain được chọn. Ví dụ: `iptables -t nat -n -L`;       `iptables -L -v`.|
|**-F, --flush** *[chain]*|Flush the selected chain (all the chains in the table if none is given). This is equivalent to deleting all the rules one by one.| Flush một chain được chọn|
|**-Z, --zero** *[chain]*| Zero the packet and byte counters in all chains. It is legal to specify the -L, --list (list) option as well, to see the counters immediately before they are cleared. (See above.)||
|**-N, --new-chain** *chain*| Create a new user-defined chain by the given name. There must be no target of that name already.|Tạo một chain mới|
|**-X, --delete-chain** *[chain]*|Delete the optional user-defined chain specified. There must be no references to the chain. If there are, you must delete or replace the referring rules before the chain can be deleted. The chain must be empty, i.e. not contain any rules. If no argument is given, it will attempt to delete every non-builtin chain in the table.|Xóa một chain|
|**-P, --policy** *chain target*| Set the policy for the chain to the given target. See the section TARGETS for the legal targets. Only built-in (non-user-defined) chains can have policies, and neither built-in nor user-defined chains can be policy targets.| |
|**-E, --rename-chain** *old-chain new-chain*|Rename the user specified chain to the user supplied name. This is cosmetic, and has no effect on the structure of the table.| Đổi tên chain.|
|-h| Help. Give a (currently very brief) description of the command syntax.| Liệt kê cú pháp các lệnh|

##5.2 PARAMETERS

Để xây dựng các rules bạn còn phải sử dụng các tuỳ chọn để tạo điều kiện so sánh.Sau đây là một số tuỳ chọn thường dùng.

The following parameters make up a rule specification (as used in the add, delete, insert, replace and append commands).

|PARAMETERS|Meaning|Ý nghĩa|
|:---:|:---:|:---:|
|**-p, --protocol [!]** *protocol*| The protocol of the rule or of the packet to check. The specified protocol can be one of tcp, udp, icmp, or all, or it can be a numeric value, representing one of these protocols or a different one. A protocol name from /etc/protocols is also allowed. A "!" argument before the protocol inverts the test. The number zero is equivalent to all. Protocol all will match with all protocols and is taken as default when this option is omitted.| so sánh protocol gói tin|
|**-s, --source [!]** *address[/mask]*|Source specification. Address can be either a network name, a hostname (please note that specifying any name to be resolved with a remote query such as DNS is a really bad idea), a network IP address (with /mask), or a plain IP address. The mask can be either a network mask or a plain number, specifying the number of 1's at the left side of the network mask. Thus, a mask of 24 is equivalent to 255.255.255.0. A "!" argument before the address specification inverts the sense of the address. The flag --src is an alias for this option.|so sánh địa chỉ nguồn của gói tin.|
|**-d, --destination [!]** *address[/mask]*|Destination specification. See the description of the -s (source) flag for a detailed description of the syntax. The flag --dst is an alias for this option.| so sánh địa chỉ đích của gói tin|
|**-j, --jump** *target* |This specifies the target of the rule; i.e., what to do if the packet matches it. The target can be a user-defined chain (other than the one this rule is in), one of the special builtin targets which decide the fate of the packet immediately, or an extension (see EXTENSIONS below). If this option is omitted in a rule (and -g is not used), then matching the rule will have no effect on the packet's fate, but the counters on the rule will be incremented.|Nhẩy đến một kiểu xử lý (target) tương ứng như đã định nghĩa ở trên nếu điều kiện so sánh thoả mãn.|
|**-g, --goto** *chain*|This specifies that the processing should continue in a user specified chain. Unlike the --jump option return will not continue processing in this chain but instead in the chain that called us via --jump.||
|**-i, --in-interface [!]** *name*|Name of an interface via which a packet was received (only for packets entering the INPUT, FORWARD and PREROUTING chains). When the "!" argument is used before the interface name, the sense is inverted. If the interface name ends in a "+", then any interface which begins with this name will match. If this option is omitted, any interface name will match.| so sánh tên card mạng mà gói tin đi vào hệ thống qua đó|
|**-o, --out-interface [!]** *name*|Name of an interface via which a packet is going to be sent (for packets entering the FORWARD, OUTPUT and POSTROUTING chains). When the "!" argument is used before the interface name, the sense is inverted. If the interface name ends in a "+", then any interface which begins with this name will match. If this option is omitted, any interface name will match.|so sánh tên card mạng mà gói tin từ hệ thống đi ra qua đó.|
|**[!] -f, --fragment**|This means that the rule only refers to second and further fragments of fragmented packets. Since there is no way to tell the source or destination ports of such a packet (or ICMP type), such a packet will not match any rules which specify them. When the "!" argument precedes the "-f" flag, the rule will only match head fragments, or unfragmented packets.|
|**-c, --set-counters** *PKTS BYTES*|This enables the administrator to initialize the packet and byte counters of a rule (during INSERT, APPEND, REPLACE operations).|


##5.3 OTHER OPTIONS

The following additional options can be specified:

|OPTIONS|Meaning|Ý nghĩa|
|:---:|:---:|:---:|
|**-v, --verbose**|Verbose output. This option makes the list command show the interface name, the rule options (if any), and the TOS masks. The packet and byte counters are also listed, with the suffix 'K', 'M' or 'G' for 1000, 1,000,000 and 1,000,000,000 multipliers respectively (but see the -x flag to change this). For appending, insertion, deletion and replacement, this causes detailed information on the rule or rules to be printed.|
|**-n, --numeric**|Numeric output. IP addresses and port numbers will be printed in numeric format. By default, the program will try to display them as host names, network names, or services (whenever applicable).|
|**-x, --exact**|Expand numbers. Display the exact value of the packet and byte counters, instead of only the rounded number in K's (multiples of 1000) M's (multiples of 1000K) or G's (multiples of 1000M). This option is only relevant for the -L command.|
|**--line-numbers**|When listing rules, add line numbers to the beginning of each rule, corresponding to that rule's position in the chain.|
|**--modprobe=command**|When adding or inserting rules into a chain, use command to load any necessary modules (targets, match extensions, etc).

##5.4 Match Extensions



#6. Case trong thực tế.

<a name="thamkhao"></a>
#Tài liệu tham khảo
- Michal Rash, Linux firewall: Attack Detection and response with iptables, psad and fwsnort.
- Paul Cobbaut, Linux Networking.
- LeRoy D. Cressy, Iptables.
- http://www.faqs.org/docs/iptables/
- http://linux.die.net/man/8/iptables
- http://www.linuxhomenetworking.com/wiki/index.php/Quick_HOWTO_:_Ch14_:_Linux_Firewalls_Using_iptables#.V6ap8Zh97IU
- https://github.com/NguyenHoaiNam/Iptables-trong-Linux
