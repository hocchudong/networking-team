#Match Extensions and Target Extensions
#Mục lục
#1.
##1.1 connlimit: 
Cho phép bạn giới hạn số lượng kết nối TCP song song với một máy chủ cho mỗi địa chỉ IP của khách hàng (hoặc khối địa chỉ).

|Command|Ý nghĩa|
|:---:|:---:|
|[!] **--connlimit-above** n|  phù hợp nếu số lượng kết nối TCP hiện tại là (không) trên n|
| **--connlimit-mask** bits| nhóm hosts sử dụng mask|

Ví dụ:
```sh
#Cho phép 2 kết nối telnet trên mỗi client.
# allow 2 telnet connections per client host
iptables -p tcp --syn --dport 23 -m connlimit --connlimit-above 2 -j REJECT
```



##1.2 conntrack



##1.3 hashlimit



##1.4 iprange
##1.5 length
##1.6 limit
Dùng để giới hạn tốc độ. Firewall sẽ chấp nhận các gói tin cho đến khi đạt giá trị limit.

|Command|Ý nghĩa|
|:---:|:---:|
|**--limit** *rate*|Maximum average matching rate: specified as a number, with an optional '/second', '/minute', '/hour', or '/day' suffix; the default is 3/hour.|
|**--limit-burst** *number*|Maximum initial number of packets to match: this number gets recharged by one every time the limit specified above is not reached, up to this number; the default is 5.|

##1.7 mport



##1.8 multiport
Có thể Match số lượng lớn các cổng nguồn và đích. Có thể lên đến 15 cổng. port range (port:port) được tính như là 2 cổng. Được sử dụng với **-p tcp** hoặc **-p udp**.

|Command|Ý nghĩa|
|:---:|:---:|
|**--sport** *< port, port >*| xác định một loạt các giá trị port nguồn|
|**--dport** *< port, port >*| xác định một loạt các giá trị port đích.|
|**--port** *< port, port >*| xác định một loạt các giá trị port (không phân biệt nguồn hay đích).|

##1.9 mac
Match địa chỉ mac nguồn

|Command|Ý nghĩa|
|:---:|:---:|
|**--mac-source** *address* | Match địa chỉ mac nguồn. Nó có dạng là XX:XX:XX:XX:XX:XX. Chú ý, chỉ có tác dụng với thiết bị Ethernet và chain PREROUTING, FORWARD, INPUT|


##1.10 recent
Module này cho phép ta tạo ra một danh sách động chứa địa chỉ ip, rồi thực thi các hành động với danh sách này.

|Command|Ý nghĩa|
|:---:|:---:|
|**--name** http| Đặt tên cho danh sách là http. Nếu không có tùy chọn này, mặc định tên sẽ là DEFAULT.|
|**--set**| Sẽ thêm các địa chỉ nguồn của gói tin vào danh sách.|
|**--update**| Kiểm tra xem địa chỉ nguồn của gói tin đã có trong danh sách không và sẽ cập nhật thêm phần `last_seen` của gói tin.|
|**--seconds** 20, **--hitcount ** 11| Số kết nối trong khoảng thời gian cụ thể. Ở đây là 10 kết nối trong 20s. 

## 1.11set
##1.12 state
Xác định trạng thái kết nối mà gói tin thể hiện

|Command|Ý nghĩa|
|:---:|:---:|
|**---state** *<state>*| : **ESTABLISHED:** gói tin thuộc một kết nối đã được thiết lập. **NEW:** gói tin thể hiện một yêu cầu kết nối. **RELATED:** gói tin thể hiện một yêu cầu kết nối thứ hai (có liên quan đến kết nối thứ nhất, thường xuất hiện ở những giao thức FPT hay ICMP). **INVALID:** thể hiện một gói tin không hợp lệ|

Ví dụ:
```sh
iptables -A INPUT -i $IF -d $IP -m state --state ESTABLISHED,RELATED -j ACCEPT
```

Nếu rule trên không có thông số và giá trị của thông số **-m state** thì firewall này hoàn toàn vô dụng bởi vì nó cho phép bất cứ giao thức nào, ở tình trạng nào cũng có thể lưu thông. Với -m state, packets đi vào sẽ được kiểm duyệt tình trạng của packets thoả mãn điều kiện **ESTABLISHED** hoặc **RELATED**. Cũng nên đào sâu vài điểm về tình trạng ESTABLISHED và RELATED ở đây: 

- Một packet ở tình trạng ESTABLISHED có nghĩa nó thuộc một xuất truy cập (connection) đã hình thành và xuất truy cập này đã có diễn tiến trao đổi các packet từ hai phía "gởi và nhận". Với các luật ở dòng 10 và 11, chúng ta dễ thấy chỉ có packet từ firewall đi ra mới có thể ở tình trạng NEW để khởi tạo một xuất truy cập. Hay nói một cách khác, firewall của bạn "hỏi" thì đối tượng nào đó từ Internet mới "trả lời". Packet ở tình trạng ESTABLISHED có nghĩa là nó đã thông qua giai đoạn "hỏi / trả lời" một cách hợp thức. Điều này cũng có nghĩa, packets từ bên ngoài đi đến $IP xuyên qua $IF sẽ không được tiếp nhận ở tình trạng NEW và INVALID cho nên các packets nào "hỏi" (NEW) hoặc "chen ngang" (INVALID) từ bên ngoài đến firewall sẽ bị chặn (tham khảo thêm tài liệu căn bản về iptables cho 4 states được sử dụng). 

- Packet ở tình trạng RELATED không thấy nhiều như packet ở tình trạng ESTABLISHED bởi vì RELATED packet chỉ xuất hiện khi một xuất truy cập mới cần được thiết lập dựa trên tình trạng một xuất truy cập đang có đã được thiết lập một cách hợp pháp. Loại packet này có thể thấy ở giao thức FTP sau khi phân đoạn kết nối và xác minh người dùng (authentication) trên cổng 21 đã hoàn thành và cần thiết lập cổng dữ liệu 20 để chuyển tải dữ liệu. Ở đây, vì giao thức qua cổng 21 ở dạng ESTABLISHED cho nên cổng 20 được phép thiết lập thêm và phân đoạn này tạo ra packet thuộc dạng RELATED. Packet ở tình trạng RELATED cũng thường thấy ở các ICMP packets ở dạng trả lời (replies). 

- -m state ở trên là một trong những tính năng thuộc dạng SPI -1- (stateful packet inspection - kiểm soát đa thể trạng) của iptables. Trước đây, với kernel 2.2.x series và ipchains (tiền thân của iptables), các packets được kiểm soát ở giới hạn loại packet và không thể kiểm soát ở biên độ tình trạng packet. Tính năng đa thể trạng này không những giúp bạn đơn giản hoá nhóm luật cho firewall của mình mà còn tạo nên một firewall linh động và vững vàng hơn rất nhiều. Nếu không dùng -m state ở đây, ít nhất bạn phải mở một loạt cổng nào đó (dãy 32000 - 64000 chẳng hạn) để các packets từ bên ngoài có thể đi vào để "trả lời" các requests bạn tạo ra. Đây là một phương thức có thể tạo những điểm yếu cho firewall, đó là chưa kể đến tính luộm thuộm khi phải cho phép chuỗi cổng cho mỗi loại giao thức (tcp / udp) và loại icmp ra vào cho thích hợp. 

Diễn dịch luật này thành ngôn ngữ bình thường như sau: mọi packets từ bên ngoài Internet đi vào IP hiện dụng (-s $IP) xuyên qua interface eth0 (-i $IF) vào trong máy ở chế độ ESTABLISHED,RELATED thì được chấp nhận (-j ACCEPT). 




##1.13 tcp
##1.14 tcpmss
##1.15 tos
##1.16 ttl
##1.17 udp









#Target Extensions

#Tài liệu tham khảo
http://linux.die.net/man/8/iptables
http://www.hvaonline.net/hvaonline/posts/list/0/105.hva

