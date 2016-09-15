#IP sets
IP sets là một framework ở bên trong kernel Linux, là công cụ hữu ích quản lý địa chỉ ip.
IP sets có thể lưu trữ IP address, networks, (tcp/udp) port numbers, MAC address, interface name hoặc kết hợp những cái trên.

IP sets có thể giúp bạn: 
- Lưu trữ nhiều địa chỉ IP hoặc port numbers và kết hợp với IPTables để tạo rules.
- Tự động cập nhật các địa chỉ IP hoặc port hiệu quả.
- Đơn giản hóa các rules của IPTables. Sử dụng IP sets có tốc độ nhanh hơn so với IPTables.
Bởi vì ipset được lữu trữ dưới dạng cấu trúc dữ liệu, hỗ trợ tìm kiếm hiệu quả hơn.
Khác với iptables chain được lưu trữ và xử lý tuyến tính.

# Mục lục
**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*

- [1. Cài đặt](#caidat)
- [2. Commands](#command)
	- [2.1 COMMANDS](#commands)
	- [2.2 OTHER OPTIONS](#options)
	- [2.3 CREATE AND ADD OPTIONS](#other_options)
	- [2.4 SET TYPES](#types)
		- [2.4.1 bitmap:ip](#bitmap_ip)
		- [2.4.2 bitmap:ip,mac](#bitmap_ip_mac)
		- [2.4.3 bitmap:port](#bitmap_port)
		- [2.4.4 hash:ip](#hash_ip)
		- [2.4.5 hash:mac](#hash_mac)
		- [2.4.6 hash:net](#hash_net)
		- [2.4.7 hash:net,net](#)
		- [2.4.8 hash:ip,port](#hash_ip_port)
		- [2.4.9 hash:net,port](#hash_net_port)
		- [2.4.10 hash:ip,port,ip](#)
		- [2.4.11 hash:ip,port,net](#)
		- [2.4.12 hash:ip,mark](#ha)
	- [2.5 Lưu và khôi phục lại cấu hình của ipset](#save_restore)
- [3. Kết hợp IPTables và IP sets.](#iptables_ipsets)
- [4. Demo](#demo)
- [5. Tài liệu tham khảo](#thamkhao)

<a name="caidat"></a>
#1. Cài đặt
- Trên ubuntu
```sh
apt-get install ipset  
```

- Trên CentOS
```sh
yum install ipset  
```

- Trên các nền tảng khác: Tiến hành tải source code về và biên dịch.
```sh
git://git.netfilter.org/ipset.git
```

<a name="command"></a>
#2. Commands
IPsets là một match extension của iptables. Để sử dụng nó, bạn sẽ tạo các set bằng lệnh ipset, sau đó sử dụng nó để
chỉ định match specifition của một rule trong iptables.

- Câu lệnh
```sh
ipset [ OPTIONS ] COMMAND [ COMMAND-OPTIONS ]
```
Trong đó: 

COMMANDS := { create | add | del | test | destroy | list | save | restore | flush | rename | swap | help | version | - }

OPTIONS := { -exist | -output { plain | save | xml } | -quiet | -resolve | -sorted | -name | -terse | -file filename }

<a name="commands"></a>
##2.1 COMMANDS
|Command|Ý nghĩa|
|:---:|:---:|
|**n, create** SETNAME TYPENAME [ CREATE-OPTIONS ]| Tạo một set (danh sách) với tên là SETNAME và xác định kiểu lưu trữ (TYPENAME). Nếu có tùy chọn **-exist**, ipset sẽ bỏ qua lỗi trùng tên set|
|**add** SETNAME ADD-ENTRY [ ADD-OPTIONS ]| Thêm một entry vào set (danh sách). Nếu có tùy chọn **-exist**, ipset sẽ bỏ qua nếu entry đã có trong set (danh sách).|
|**del** SETNAME DEL-ENTRY [ DEL-OPTIONS ]| Xóa bỏ một entry từ set (danh sách). Nếu có tùy chọn **-exist**, và trong set (danh sách) không có entry này thì ipset sẽ bỏ qua|
|**test** SETNAME TEST-ENTRY [ TEST-OPTIONS ]| Kiểm tra xem trong set (danh sách) có entry này hay không|
|**x, destroy** [ SETNAME ]| Xóa bỏ set (danh sách). Nếu không chỉ ra set (danh sách) nào thì ipset sẽ xóa bỏ hết toàn bộ|
|**list** [ SETNAME ] [ OPTIONS ]| Liệt kê tất cả các header data và các entry của set (danh sách) |
|**save** [ SETNAME ]| Lưu thông tin về set (danh sách) ra màn hình|
|**restore**| Khôi phục lại các thông tinh về set đã lưu. Đọc từ màn hình.|
|**flush** [ SETNAME ]| Xóa bỏ các entry trong set. Nếu không chỉ ra set nào thì sẽ xóa bỏ entry trên toàn bỏ các set. |
|**e, rename** SETNAME-FROM SETNAME-TO| Đổi tên set.|
|**w, swap** SETNAME-FROM SETNAME-TO| Tráo đổi nội dung của 2 set.|

<a name="options"></a>
##2.2 OTHER OPTIONS
|Command|Ý nghĩa|
|:---:|:---:|
|-!, -exist| Bỏ qua lỗi khi có cùng tên set được tạo hoặc đã tồn tại entry trong set|
|-o, -output { plain / save / xml }| Chọn định dạng khi xuất ra|
|-q, -quiet| Suppress any output to stdout and stderr. ipset will still exit with error if it cannot continue.|
|-r, -resolve| Chương trình sẽ resolved từ địa chỉ IP sang hostname.|
| -s, -sorted| Sorted output.|
|-n, -name| Liệt kê tên các set đã tồn tại|
|-t, -terse| Liệt kê các tên các set và headers của set đó|
|-f, -file *filename*| Chỉ định 1 tệp để list hoặc save, restore|

<a name="other_options"></a>
##2.3 CREATE AND ADD OPTIONS
|Command|Ý nghĩa|
|:---:|:---:|
|timeout| Mỗi entry khi đạt đến thời gian timeout thì sẽ bị xóa khỏi set. Ví dụ: `ipset create test hash:ip timeout 300. ipset add test 192.168.0.1 timeout 60` |
|counters, packets, bytes| Thiết lập bộ đếm các packet, kích thước các packet này. `ipset create foo hash:ip counters`|
|comment|Thêm chú thích với một chuỗi bất kỳ. `ipset create foo hash:ip comment. "this comment is \"bad\""`|
|skbinfo, skbmark, skbprio, skbqueue| Cho phép lưu trữ các thông tin (firewall mark, tc class and hardware queue) với mỗi entry và map chúng vào packet sử dụng target `--map-set`.|
|hashsize| Cho phép ta tùy chỉnh kích thước của hash khi tạo set|
|maxelem| maximal number of elements được lưu trữ trong set. Dùng với lệnh create cho set kiểu hash.|
|family { inet / inet6 }| Được dùng với lệnh create với các set kiểu hash. Nó định nghĩa protocol family của địa chỉ ip address được lưu trữ trong set. Mặc định là inet. `ipset create test hash:ip family inet6`|
|nomatch| Khi entry có tùy chọn này, thì set sẽ bỏ qua entry này. Ví dụ: Ta có 1 set gồm các entry là địa chỉ ip bị block vào webserver. Nếu có 1 entry được đánh dấu là nomatch thì ip này vẫn có thể truy cập được webserver |
|forceadd|Khi add một entry vào set này, nhưng sety đã bị full, thì nó sẽ xóa đi 1 entry bất kỳ để có thể add entry mới vào. `ipset create foo hash:ip forceadd` |

<a name="types"></a>
##2.4 SET TYPES
Nếu bạn muốn lưu trữ một mạng con (subnets) từ một mạng nào đó (say /24 blocks from a /8 network), sử dụng bitmap:ip.
Nếu bạn muốn lưu trức mạng cùng kích thước, một cách ngẫu nhiên, sử dụng hash:ip.
Nếu bạn đã có kích thước ngẫu nhiên của mạng, sử dụng hash:net

<a name="bitmap_ip"></a>
###2.4.1 bitmap:ip
- Sử dụng một loại bộ nhớ, trong đó mỗi bit đại diện cho một địa chỉ IP. Có thể lưu trữ đến 65535 entries (Địa chỉ lớp B /16).
- Các OPTIONS trong set này: 
```sh
CREATE-OPTIONS := range fromip-toip|ip/cidr [ netmask cidr ] [ timeout value ] [ counters ] [ comment ] [ skbinfo ]

ADD-ENTRY := { ip | fromip-toip | ip/cidr }

ADD-OPTIONS := [ timeout value ] [ packets value ] [ bytes value ] [ comment string ] [ skbmark value ] [ skbprio value ] [ skbqueue value ]

DEL-ENTRY := { ip | fromip-toip | ip/cidr }

TEST-ENTRY := ip
```
- Ví dụ:
```sh
ipset create foo bitmap:ip range 192.168.0.0/16
ipset add foo 192.168.1/24
ipset test foo 192.168.1.1
```

<a name="bitmap_ip_mac"></a>
###2.4.2 bitmap:ip,mac
- Sử dụng một loại bộ nhớ, trong đó mỗi 8 bytes đại diện cho 1 địa chỉ ip và MAC address. Có thể lưu trữ đến 65535 địa chỉ ip kết hợp địa chỉ MAC.
- Lưu ý, chỉ có thể lưu địa chỉ MAC nguồn.
- Các OPTIONS trong set này:
```sh
CREATE-OPTIONS := range fromip-toip|ip/cidr [ timeout value ] [ counters ] [ comment ] [ skbinfo ]

ADD-ENTRY := ip[,macaddr]

ADD-OPTIONS := [ timeout value ] [ packets value ] [ bytes value ] [ comment string ] [ skbmark value ] [ skbprio value ] [ skbqueue value ]

DEL-ENTRY := ip[,macaddr]

TEST-ENTRY := ip[,macaddr]
```
- Ví dụ:
```sh
ipset create foo bitmap:ip,mac range 192.168.0.0/16
ipset add foo 192.168.1.1,12:34:56:78:9A:BC
ipset test foo 192.168.1.1
```

<a name="bitmap_port"></a>
###2.4.3 bitmap:port
- Sử dụng một loại bộ nhớ, mà trong đó mỗi bit đại diện cho một port (TCP/UDP). Có thể lưu trữ lên đến 65535 ports.

```sh
REATE-OPTIONS := range fromport-toport [ timeout value ] [ counters ] [ comment ] [ skbinfo ]

ADD-ENTRY := { [proto:]port | [proto:]fromport-toport }

ADD-OPTIONS := [ timeout value ] [ packets value ] [ bytes value ] [ comment string ] [ skbmark value ] [ skbprio value ] [ skbqueue value ]

DEL-ENTRY := { [proto:]port | [proto:]fromport-toport }

TEST-ENTRY := [proto:]port
```
- Ví dụ:
```sh
ipset create foo bitmap:port range 0-1024
ipset add foo 80
ipset test foo 80
```

<a name="hash_ip"></a>
###2.4.4 hash:ip
- Sử dụng hash để lưu trữ địa chỉ IP hoặc địa chỉ mạng. Cùng kích thước địa chỉ mạng có thể được lưu trữ trong một hash:ip.
```sh
CREATE-OPTIONS := [ family { inet | inet6 } ] | [ hashsize value ] [ maxelem value ] [ netmask cidr ] [ timeout value ] [ counters ] [ comment ] [ skbinfo ]

ADD-ENTRY := ipaddr

ADD-OPTIONS := [ timeout value ] [ packets value ] [ bytes value ] [ comment string ] [ skbmark value ] [ skbprio value ] [ skbqueue value ]

DEL-ENTRY := ipaddr

TEST-ENTRY := ipaddr
```
- Ví dụ:
```sh
ipset create foo hash:ip netmask 30
ipset add foo 192.168.1.0/24
ipset test foo 192.168.1.2
```

<a name="hash_mac"></a>
###2.4.5 hash:mac
- Sử dụng hash để lưu trữ địa chỉ MAC. 
```sh
CREATE-OPTIONS := [ hashsize value ] [ maxelem value ] [ timeout value ] [ counters ] [ comment ] [ skbinfo ]

ADD-ENTRY := macaddr

ADD-OPTIONS := [ timeout value ] [ packets value ] [ bytes value ] [ comment string ] [ skbmark value ] [ skbprio value ] [ skbqueue value ]

DEL-ENTRY := macaddr

TEST-ENTRY := macaddr
```
- Ví dụ: 
```sh
ipset create foo hash:mac
ipset add foo 01:02:03:04:05:06
ipset test foo 01:02:03:04:05:06
```

<a name="hash_net"></a>
###2.4.6 hash:net
- Sử dụng hash để lưu trữ các mạng có kích thước khác nhau (CIDR).
```sh
CREATE-OPTIONS := [ family { inet | inet6 } ] | [ hashsize value ] [ maxelem value ] [ timeout value ] [ counters ] [ comment ] [ skbinfo ]

ADD-ENTRY := netaddr

ADD-OPTIONS := [ timeout value ] [ nomatch ] [ packets value ] [ bytes value ] [ comment string ] [ skbmark value ] [ skbprio value ] [ skbqueue value ]

DEL-ENTRY := netaddr

TEST-ENTRY := netaddr
```
- Ví dụ:
```sh
ipset create foo hash:net
ipset add foo 192.168.0.0/24
ipset add foo 10.1.0.0/16
ipset add foo 192.168.0/24
```


<a name="hash_net_net"></a>
###2.4.7 hash:net,net

<a name="hash_ip_port"></a>
###2.4.8 hash:ip,port
- Sử dụng hash để lưu trữ địa chỉ IP và port đi kèm.
```sh
CREATE-OPTIONS := [ family { inet | inet6 } ] | [ hashsize value ] [ maxelem value ] [ timeout value ] [ counters ] [ comment ] [ skbinfo ]

ADD-ENTRY := ipaddr,[proto:]port

ADD-OPTIONS := [ timeout value ] [ packets value ] [ bytes value ] [ comment string ] [ skbmark value ] [ skbprio value ] [ skbqueue value ]

DEL-ENTRY := ipaddr,[proto:]port

TEST-ENTRY := ipaddr,[proto:]port
```
```sh
ipset create foo hash:ip,port
ipset add foo 192.168.1.0/24,80-82
ipset add foo 192.168.1.1,udp:53
ipset add foo 192.168.1.1,vrrp:0
ipset test foo 192.168.1.1,80
ipset add set6 192.168.1.1,icmp:ping
```

<a name="hash_net_port"></a>
###2.4.9 hash:net,port
- Sử dụng hash để lưu trữ địa chỉ mạng và port đi kèm
```sh
CREATE-OPTIONS := [ family { inet | inet6 } ] | [ hashsize value ] [ maxelem value ] [ timeout value ] [ counters ] [ comment ] [ skbinfo ]

ADD-ENTRY := netaddr,[proto:]port

ADD-OPTIONS := [ timeout value ] [ nomatch ] [ packets value ] [ bytes value ] [ comment string ] [ skbmark value ] [ skbprio value ] [ skbqueue value ]

DEL-ENTRY := netaddr,[proto:]port

TEST-ENTRY := netaddr,[proto:]port
```
- Ví dụ:
```sh
ipset create foo hash:net,port
ipset add foo 192.168.0/24,25
ipset add set9 192.168.1.0/24,tcp:443
ipset test foo 192.168.0/24,25
```

###2.4.10 hash:ip,port,ip
###2.4.11 hash:ip,port,net


###2.4.12 hash:ip,mark
- Sử dụng hash để lưu trữ địa chỉ ip và đánh dấu các gói tin đi kèm với địa chỉ ip này.
```sh
CREATE-OPTIONS := [ family { inet | inet6 } ] | [ markmask value ] [ hashsize value ] [ maxelem value ] [ timeout value ] [ counters ] [ comment ] [ skbinfo ]

ADD-ENTRY := ipaddr,mark

ADD-OPTIONS := [ timeout value ] [ packets value ] [ bytes value ] [ comment string ] [ skbmark value ] [ skbprio value ] [ skbqueue value ]

DEL-ENTRY := ipaddr,mark

TEST-ENTRY := ipaddr,mark
```
- markmask value: Cho phép bạn thiết lập các bit bạn quan tâm đến các gói tin được đánh dấu.
- Giá trị của mark từ 0 đến 4294967295.
- Ví dụ:
```sh
ipset create foo hash:ip,mark
ipset add foo 192.168.1.0/24,555
```


###2.4.13 hash:net,port,net


###2.4.14 hash:net,iface
- Sử dụng hash để lưu trữ các địa chỉ mạng có kích thước khác nhau đi kèm với interface.
```sh
CREATE-OPTIONS := [ family { inet | inet6 } ] | [ hashsize value ] [ maxelem value ] [ timeout value ] [ counters ] [ comment ] [ skbinfo ]

ADD-ENTRY := netaddr,[physdev:]iface

ADD-OPTIONS := [ timeout value ] [ nomatch ] [ packets value ] [ bytes value ] [ comment string ] [ skbmark value ] [ skbprio value ] [ skbqueue value ]

DEL-ENTRY := netaddr,[physdev:]iface

TEST-ENTRY := netaddr,[physdev:]iface
```
- Ví dụ:
```sh
ipset create foo hash:net,iface
ipset add foo 192.168.0/24,eth0
ipset add foo 10.1.0.0/16,eth1
ipset test foo 192.168.0/24,eth0
```


###2.4.15 list:set
- Sẽ tạo ra một set mà chứa danh sách entry là tên các set khác.
```sh
CREATE-OPTIONS := [ size value ] [ timeout value ] [ counters ] [ comment ] [ skbinfo ]

ADD-ENTRY := setname [ { before | after } setname ]

ADD-OPTIONS := [ timeout value ] [ packets value ] [ bytes value ] [ comment string ] [ skbmark value ] [ skbprio value ] [ skbqueue value ]

DEL-ENTRY := setname [ { before | after } setname ]

TEST-ENTRY := setname [ { before | after } setname ]
```

- size value: Kích thước của list. Mặc định là 8

-Ví dụ:
```sh
ipset add set1 set3 set5
```

<a name="save_restore"></a>
##2.5 Lưu và khôi phục lại cấu hình của ipset
- Để Lưu vào file `/etc/ipset/ipset.conf`
```sh
ipset save > /etc/ipset/ipset.conf
```

- Khôi phục lại cấu hình từ file `/etc/ipset/ipset.conf`
```sh
ipset restore < /etc/ipset/ipset.conf
```

<a name="iptables_ipsets"></a>
#3. Kết hợp IPTables và IP sets.
- Sử dụng module **set** để kết hợp giữa IPTables và IP sets.

|Command|Ý nghĩa|
|:---:|:---:|
|--set setname flag[,flag...]| flag là src (địa chỉ nguồn) hoặc dst (địa chỉ đích). Ví dụ `iptables -A FORWARD -m set --set test src,dst
`|

- TARGET SET: Để thêm hoặc xóa các entries của ipset nhờ IPTables.

|Command|Ý nghĩa|
|:---:|:---:|
|--add-set setname flag[,flag...]| Thêm địa chỉ hoặc port vào set. Flag là src hoặc dst|
|--del-set setname flag[,flag...]| Xóa địa chỉ hoặc port của set. Flag là src hoặc dst|


<a name="demo"></a>
#4. Demo
<a name="thamkhao"></a>
#5. Tài liệu tham khảo
- http://ipset.netfilter.org/
- http://ipset.netfilter.org/ipset.man.html
- https://workshop.netfilter.org/2013/wiki/images/a/ab/Jozsef_Kadlecsik_ipset-osd-public.pdf
- http://linux.die.net/man/8/iptables


