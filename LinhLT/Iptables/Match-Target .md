#Match Extensions and Target Extensions
#Mục lục
#1.Match Extensions
##1.1 connlimit: 
Cho phép bạn giới hạn số lượng kết nối TCP song song với một máy chủ cho mỗi địa chỉ IP của khách hàng (hoặc khối địa chỉ).

|Command|Ý nghĩa|
|:---:|:---:|
|[!] **--connlimit-above** n|  phù hợp nếu số lượng kết nối TCP hiện tại là (không) trên n|
| **--connlimit-mask** bits| nhóm hosts sử dụng mask|
| **--connlimit-upto** n| Ngược lại với above|


###1.1.1 Ví dụ:

```sh
iptables -A INPUT -i $IF -p tcp --syn -s $NET --sport $HI_PORTS -d $IP --dport $port -m state --state NEW -m connlimit ! --connlimit-above 2 -j ACCEPT
```

-m connlimit ! --connlimit-above 2 quyết định tối hậu đến số phận các gói tin đi vào ngoài các áp đặt đi trước (như gói tin TCP phải mang flag SYN và phải ở tình trạng NEW). Tính linh động nằm ở giá trị đảo (!) phía trước --connlimit-above 2. Dòng lệnh này áp đặt thêm một tầng kiểm soát: các gói tin truy cập này đến từ một IP mà không nhiều hơn 2 xuất truy cập thì tiếp nhận. 3, 4 hoặc hơn xuất truy cập không thể xảy ra từ cùng một máy con (có cùng IP) đến máy chủ. Tính chất này khác hẳn tính chất "connection rate", "connection limit" dựa trên tính đồng thời (concurrent) của giao thức TCP mà điều tác 

Giao thức TCP mang tính đồng thời (concurrent). Mỗi dịch vụ TCP đang hoạt động ở tình trạng "lắng nghe" (LISTEN) trên một cổng dịch vụ nào đó. Tình trạng này duy trì cho đến khi nào dịch vụ này được tắt bỏ hoặc bị tắt bỏ (vì bị treo, chẳng hạn). 

Cứ mỗi xuất truy cập từ một máy con vào dịch vụ TCP trên server của chúng ta sẽ, 
- được tạo ra một socket riêng biệt và socket này tồn tại cho đến khi xuất truy cập giữa máy con và máy chủ kết thúc. 
- mỗi xuất truy cập mang cổng nguồn (source port) khác nhau trên máy con và, 
- máy chủ phải có trách nhiệm phục vụ từng xuất truy cập trên từng cổng của máy con. 

Dựa trên tính chất này, chúng ta thấy một máy con có thể đòi hỏi nhiều xuất truy cập cùng một lúc và máy chủ có thể đáp ứng yêu cầu này theo đúng tính chất hoạt động của TCP. Tuy nhiên, điểm cần đưa ra ở đây thuộc phạm trù bảo mật là, nếu máy con yêu cầu nhiều xuất truy cập mang tính "ác ý" (như một dạng DoS) chẳng hạn thì sao? Tình trạng có thể xảy ra: 
- máy chủ vận động nhiều process để tạo các socket đáp ứng máy con 
- máy chủ có thể bị cạn kiệt tài nguyên dự trữ để tạo socket 
- dịch vụ được yêu cầu truy cập có thể bị mất hiệu năng vì không đáp ứng kịp với quá nhiều yêu cầu 
- các dịch vụ liên hệ bị treo hoặc không thể tiếp tục hoạt động vì tài nguyên trên máy bị cạn kiệt 
- các máy con khác không thể truy cập máy chủ vì máy chủ không còn khả năng đáp ứng, 
- và điều tệ hại nhất là máy chủ bị hoàn toàn tê liệt vì quá tải. 

Nói một cách công bằng, dịch vụ trên máy của cố gắng đáp ứng các yêu cầu theo đúng chức năng nhưng vì không đủ tài nguyên nên phải dẫn đến tình trạng trên. vậy, bao nhiêu tài nguyên thì đủ cho máy chủ? Con số này phải được hình thành từ quá trình theo dõi và đúc kết số lần truy cập, tầng số truy cập... trên máy chủ. Trên bình diện bảo mật, firewall có thể dùng để trợ giúp các dịch vụ bằng cách hạn chế các xuất truy cập "concurrent". 

###1.1.2 Thử nghiệm
```sh
iptables -A INPUT -i eth0 -d 10.10.10.200 -p tcp --dport 22 -m state --state NEW -m connnlimit ! --connlimit-above 2 -j ACCEPT
```

Khi kết nối ssh thứ 3 thì ngay lập tức bị lỗi 
![](http://image.prntscr.com/image/1a70035b56b544638f70fe970d1cb902.png)


##1.2 limit
Dùng để giới hạn tốc độ. Firewall sẽ chấp nhận các gói tin cho đến khi đạt giá trị limit.

|Command|Ý nghĩa|
|:---:|:---:|
|**--limit** *rate*|Maximum average matching rate: specified as a number, with an optional '/second', '/minute', '/hour', or '/day' suffix; the default is 3/hour.|
|**--limit-burst** *number*|Maximum initial number of packets to match: this number gets recharged by one every time the limit specified above is not reached, up to this number; the default is 5.|

Ví dụ: 
```sh
$IPT -A INPUT -i $IF -p tcp --syn -s $NET --sport $HI_PORTS -d $IP --dport $port -m limit --limit 3/s --limit-burst 5 -m state --state NEW -j ACCEPT
```

Chuỗi -m limit --limit 3/s --limit-burst 3 dùng CONFIG_IP_NF_MATCH_LIMIT trên netfilter, một "match" trong gói căn bản và đã được tích hợp vào Linux kernel. "limit match" này ảnh hưởng lớn lao đến dòng lệnh trên bình diện giới hạn "connection rate". Chuỗi này ấn định các gói tin mang SYN flag từ một IP nào đó truy cập đến cổng dịch vụ của máy chủ ở tình trạng NEW. Trong chuỗi -m limit --limit 3/s --limit-burst 3 này, khi ứng dụng trong dòng lệnh, một gói tin sẽ được xử lý theo cơ chế: 
--limit-burst ấn định giá trị số lần (cho phép hoặc không cho phép) một gói tin được đi đến bước kế tiếp trong luật (-j ACCEPT hoặc -j DROP hoặc bất cứ "jump to" nào). Mỗi giá trị của --limit-burst là một "giấy phép", mỗi packet trùng với luật này sẽ dùng hết một "giấy phép". Khi --limit-burst bằng 0, gói tin trùng với luật đã hết "giấy phép", thì mọi gói tin mới đi vào dù có trùng với luật quy định hay không đều sẽ không thể "jump" đến target ACCEPT (và do đó sẽ bị DROP bởi policy của firewall hoặc các luật đi theo sau). Vì lý do này, --limit 3/s chính là cơ chế "nạp" giấy phép lại cho --limit-burst. Chuỗi này có ý nghĩa là mỗi 1/3 giây, sẽ tăng --limit-burst lên 1, cho đến khi đạt giá trị tối đa ban đầu (= 3 trong trường hợp này) thì sẽ không tăng nữa. 

Cụ thể hơn, tưởng tượng đang có một máy con nào đó truy cập vào máy chủ của chúng ta với tốc độ 50 packet/giây, có nghĩa là cứ 1/50 giây có một packet đi đến máy chủ. Rule trên sẽ xử lí như sau: 
-Trong vòng (1/50)*5 = 1/10 giây đầu tiên, 5 giấy phép ban đầu đã được sử dụng hết, gọi thời điểm này là T1 (chẳng hạn). Từ thời điểm T1 trở đi cho đến thời điểm T1+1/3 giây, tất cả packet từ IP này truy cập vào máy chủ sẽ bị DROP. 
-Tại thời điểm T1 + 1/3 giây, do qui định của chuỗi --limit 3/s, một giấy phép được nạp vào cho --limit-burst, nhưng gần như ngay tức khắc, giấy phép này được một packet của máy A sử dụng và do đó --limit-burst lại trở về 0 (tiếp tục hết "giấy phép"). Cứ tiếp tục như thế, sau 1/3 giây, sẽ có một packet được chấp nhận và chỉ 1 mà thôi nếu máy A cứ tiếp tục truy cập với tốc độ như trên vào máy chủ. 

Nếu máy con ngừng truy cập vào máy chủ thì diễn biến sẽ như sau: 
- Cứ sau 1/3 giây, một giấy phép sẽ được nạp vào --limit-burst, và vì bây giờ không còn packet nào được gửi đến do đó --limit-burst sẽ giữ nguyên giá trị. Cứ thể --limit-burst tăng dần cho đến khi chạm quy định ban đầu là 3 thì sẽ ngừng lại, "giấy phép" hoàn toàn ở tình trạng nguyên thuỷ. Trong thời gian --limit-burst tăng lại giá trị ban đầu, nếu máy A lại tiếp tục gửi packet thì những packet này sẽ sử dụng giấy phép trong limit-burst, và lại giảm limit-burst xuống, nếu limit-brust bằng 0 thì tất nhiên firewall sẽ tiếp tục cản các gói tin ở dạng này nếu vẫn tiếp tục vi phạm luật cho đến khi --limit-burst được giải toả (như đã giải thích). 

Đây chỉ là một ví dụ minh hoạ ứng dụng -m limit. Bạn cần khảo sát số lượng truy cập đến dịch vụ nào đó trên máy chủ trước khi hình thành giá trị thích hợp cho -m limit. Nên cẩn thận trường hợp một proxy server chỉ có một IP và có thể có hàng ngàn người dùng phía sau proxy; ghi nhận yếu tố này để điều chỉnh limit rate cho hợp lý. 

###1.2.1 Thử nghiệm

- Mô hình: 
![](http://i.imgur.com/Gdm8NoR.jpg)

	- IPTables chạy trên Ubuntu server 14.04, có địa chỉ là 10.10.10.200
	- Attacker sử dụng phần mềm hping3 để gửi liên tục các gói tin để server.
	=> Sử dụng IPTables để ngăn chặn các gói tin không hợp lệ này.

###1.2.2 Trên máy Attacker.
- Cài đặt phần mềm hping3 để gửi nhiều gói tin với tốc độ nhanh đến server
```sh
apt-get install hping3
```

- Tiến hành chặn bắt các gói tin
```sh
tcpdump -i eth0 -w abc.pcap
```
=> Dòng lệnh trên sẽ bắt các gói tin đi ra đi vào từ cổng eth0 và ghi vào file abc.pcap. Từ đó, chúng ta sẽ dễ dàng để phân tích các gói tin.

-  Tiến hành gửi gói tin: 
```sh
hping3 -V -i u10000 -1 -c 10 10.10.10.200 
```
- Giải thích tùy chọn các lệnh: 
	- -V: hiển thị thông tin các kết quả các gói tin ra màn hình.
	- -i u10000: Hping sẽ gửi với tốc độ 10 packets/s
	- -1: Gửi gói tin ICMP (PING)
	- -c 10: Gửi 10 gói tin.
	- 10.10.10.200: Địa chỉ tấn công

- Phân tích: Dòng lệnh trên sẽ gửi 10 gói tin ICMP với tốc độ 10packet/s đến webserver. Có nghĩa là 1 gói tin được gửi đi với thời gian 0.1s


###1.2.3 Trên ubuntu server.
- Tiến hành chạy các lệnh sau:
```sh
iptables -P INPUT DROP
iptables -A INPUT -p icmp -m limit --limit 10s --limit-burst 3 -j ACCEPT
iptables -A INPUT -p icmp -j LOG --log-prefix "BADICMP: "
```

- Giải thích các dòng lệnh:
	- Dòng 1: Dùng để đặt policy là DROP cho chain INPUT. Có nghĩa là mặc định, các gói tin đi vào nếu không phù hợp với các rule thì sẽ bị DROP. Quy tắc này khiến cho iptables chặt chẽ hơn.
	- Dòng 2: Dùng để thiết lập module limit với gói tin icmp. --limit 10s và --limit-burst 3 có nghĩa là ban đầu, chỉ có 3 gói tin đi vào sẽ được chấp nhận. Sau đó, cứ 1/10s (0,1s) thì lại có 1 gói tin được phép đi vào. Các gói tin còn lại sẽ bị DROP và ghi lại log nhờ dòng lệnh thứ 3.
	- Dòng 3: Dùng để ghi lại LOG các gói tin icmp mà bị iptables DROP.

###1.2.4 Kết quả.
![](http://image.prntscr.com/image/e440524d0dce4ac294ef6a156ca93be8.png)

=> Có 4 gói tin được gửi đi thành công trên tổng cộng 10 gói tin.


![](http://image.prntscr.com/image/163a5e1b09804d36b9d94b26dd320e78.png)
=>Vào đọc log ta thấy có 6 gói tin bị chặn.

###1.2.5 Kiểm nghiệm
- Tiến hành phân tích gói tin pcap mà lúc đầu chung ta bắt.

![](http://image.prntscr.com/image/bf1166c0d9a34bd9ba4d67874c2e4e2a.png)

- Nhìn vào hình ảnh, ta thấy:

- Trong khoảng thời gian từ 3.18 đến 3.20, có 3 gói tin ICMP được gửi đi (theo thứ tự trong hình là 10,15,18) và được server trả lời thành công. => Chính xác với tùy chọn --limit-burst 3, tức là 3 gói tin đầu tiên sẽ được cho phép.

- Tiếp theo, ở thời gian 3.21, gói tin ICMP thứ 4 (gói 22) được gửi đi nhưng server không đáp trả. Ta nhận thấy khoảng thời gian gói tin ICMP thứ 3 và thứ 4 chỉ là 3.21 -3 .20 = 0.01 (s). Do đó sau khi đã dùng hết 3 gói tin đầu, thì thời gian 0.01s là bé hơn thời gian để tiếp tục cho phép 1 gói tin đi vào (limit=1/10s), vì vậy nên gói tin bị LOG lại và DROP.

- Ở thời gian 3.24, gói tin ICMP thứ 5 (gói 23) được gửi đi nhưng Server không đáp trả. Lý do là tương tự ở trên.

- Ở thời gian 3.25, gói tin ICMP thứ 6 (gói 24) được gửi đi nhưng Server không đáp trả. Lý do tương tự ở trên.

- Ở thời gian 3.27, gói tin ICMP thứ 7 (gói 25) được gửi đi nhưng Server không đáp trả. Lý do tương tự ở trên.

- Ở thời gian 3.28, gói tin ICMP thứ 8 (gói 26) được gửi đi và Server đã trả lời gói tin này thành công. Ta nhận thấy thời gian của gói tin ICMP thứ 8 là 3.28 trừ đi thời gian gói tin đầu tiên là 3.18 đúng = 0.1s, bằng với tùy chọn --limit 10s mà mình đã khai báo ở trên. Do đó, sắp khi dùng hết 3 gói tin đầu tiên, và sau 0.1s với gói tin đầu tiên, thì gói tin thứ 8 đã được đồng ý để đi qua.

- Ở thời gian 3.30, gói tin ICMP thứ 9 (gói 28) bị Server từ chối. Lý do là bởi vì khoảng thời gian từ gói tin thứ 8 đến gói thứ 9 là 3.30-3.28 = 0.02s bé hơn 0.1s. Do đó, gói tin bị từ chối.

- Ở thời gian 3.32, gói tin ICMP thứ 10 (gói 29) bị Server từ chối. Lý do tương tự ở trên. 

=> Kết quả cuối cùng, chỉ có 4 gói tin được phép đi qua (thứ 1, 2, 3, 8) và 6 gói tin bị chối. Phù hợp với kết quả ở trên.



##1.3 hashlimit
Tương tự với module limit, nhưng bổ sung thêm một số tính năng.

|Command|Ý nghĩa|
|:---:|:---:|
| **--hashlimit** rate| Giống với tùy chọn limit trong module limit|
| **--hashlimit-burst** num| Giống với tùy chọn limit-burst trong module limit|
| **--hashlimit-mode** srcip/srcport/dstip/dstport| Limit dựa trên ip hay port, nguồn hay đích|
| **--hashlimit-name** foo| Đặt tên file chứa danh sách các entry tại `/proc/net/ipt_hashlimit/foo` |
| **--hashlimit-htable-size** num| 
The number of buckets of the hash table
| **--hashlimit-htable-max** num| Số lượng tối đa các entry trong hash|
| **--hashlimit-htable-expire** num| Khoảng thời gian sau bao lâu thì hash entry hết hạn|
|**--hashlimit-htable-gcinterval** num| How many miliseconds between garbage collection intervals|


- dstip: Sẽ lưu lại các entry trong bảng hash dựa trên địa chỉ đích gủa gói tin.
- dstport: Sẽ lưu lại các entry trong bảng hash dựa trên cổng đích của gói tin.
- srcip: Sẽ lưu lại các entry trong bảng hash dựa trên địa chỉ nguồn của gói tin
- srcport: Sẽ lưu lại các entry trong bảng hash dựa trên cổng nguồn gủa gói tin

###1.3.1 Thử nghiệm
Tương tự với mô hình mà mình đã thử nghiệm ở module limit, chỉ khác ở chỗ là lúc này có cùng lúc 3 máy tấn công.

- Mô hình:
![](http://i.imgur.com/pnUpCZz.jpg)

###1.3.2 Trên máy iptables

- Chạy lệnh rule iptables
```sh
iptables -P INPUT DROP
iptables -A INPUT -p icmp -m hashlimit --hashlimit 10s --hashlimit-burst 3 --hashlimit-mode srcip --hashlimit-name test -j ACCEPT
iptables -A INPUT -p icmp -j LOG --log-prefix "BADICMP: "
```

- Chạy lệnh bắt gói tin
```sh
tcpdump -i eth0 -w hashlimit.pcap
```

###1.3.3 Trên 3 máy tấn công.
- Chạy lệnh tấn công trên cả 3 máy trong cùng 1 thời điểm
```sh
hping3 -V -i u10000 -1 -c 10 10.10.10.200
```

###1.3.4 Kết quả
![](http://image.prntscr.com/image/df49808c8d1341039afdf62706fb92fb.png)

![](http://image.prntscr.com/image/6982361b737044d287f420c017a62e88.png)

![](http://image.prntscr.com/image/b0ed507b17714a1b91bbebeb4fa35175.png)

=> Mỗi máy gửi đi thành công 4 gói tin

###1.3.5 Kiểm nghiệm
![](http://i.imgur.com/ATnPP35.png)

- Tương tự như bài phân tích module limit ở trên. Trên mỗi máy chỉ có 4 gói tin đi qua và 6 gói tin bị từ chối.

=> Ở trong ví dụ trên, chứng tỏ rằng module hashlimit giới hạn dựa trên ip, phân biệt các ip nguồn (các máy khác nhau) với nhau. Điều đó thể hiện ở tùy chọn `--hashlimit-mode` mà ta đặt ở trên.

###1.3.6 Sự khác nhau giữa hashlimit và limit
Khi tôi thay đổi từ module hashlimit thành module limit và thực hiện lại các bước tấn công như trên, thì kết quả nhận được như sau

![](http://image.prntscr.com/image/5863dc05960b4dd2881c1038283f245b.png)

![](http://image.prntscr.com/image/e53704c4d65b4292a42fb61f6bbcf06a.png)

![](http://image.prntscr.com/image/f33a247a775e499e80b7738131527d16.png)

=> Mỗi máy gửi 10 gói tin => 3 máy gửi 30 gói tin, nhưng tổng cộng chỉ có 4 gói tin thành công.

Tiến hành phân tích gói tin

![](http://image.prntscr.com/image/faec3682dcc5449ba7a583b549815330.png)


**Chúng ta thấy rằng module limit giới hạn trên tất cả các ip nguồn. Có nghĩa là nó không phân biệt ip A với ip B. Chỉ cần ip A đã đạt đến giới hạn thì ip B cũng không thể truy cập được vào server.
Ngược lại module hashlimit giới hạn theo mỗi ip. ip A đã đạt giới hạn thì không thể truy cập được server, trong cùng lúc đó, ip B chưa đạt giới hạn vẫn có thể tiếp tục truy cập.**

##1.4 recent
Giới hạn số kết nối trên một khoảng thời gian. 

Module này cho phép ta tạo ra một danh sách động chứa địa chỉ ip, rồi thực thi các hành động với danh sách này.

|Command|Ý nghĩa|
|:---:|:---:|
|**--name** http| Đặt tên cho danh sách là http. Nếu không có tùy chọn này, mặc định tên sẽ là DEFAULT.|
|**--set**| Sẽ thêm các địa chỉ nguồn của gói tin vào danh sách.|
|**--update**| Kiểm tra xem địa chỉ nguồn của gói tin đã có trong danh sách không và sẽ cập nhật thêm phần `last_seen` của gói tin.|
|**--seconds** 20, **--hitcount ** 11| Số kết nối trong khoảng thời gian cụ thể. Ở đây là 10 kết nối trong 20s. 

Ví dụ cụ thể, các bạn có thể xem trong phần mở rộng của bài lab1. 

https://github.com/lethanhlinh247/networking-team/blob/master/LinhLT/Iptables/lab/lab1.md

##1.5 conntrack


##1.6 state
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

- Để hình dung rõ hơn các bạn xem ảnh này.
![](http://image.prntscr.com/image/7ae65448141e4ced9393790d052f750e.png)

=> Ở bên trái là máy server gửi các kết nối đến máy khác. Hoàn toàn ngon lành.
Tuy nhiên, máy bên phải là máy client khởi tạo kết nối mới đến server lại bị lỗi, bởi vì iptables đã ngăn chặn các gói tin khởi tạo kết nối. :D



##1.7 tcp
Sử dụng với các giao thức tcp

|Command|Ý nghĩa|
|:---:|:---:|
|**--source-port** [!] port[:port]| Xác định port nguồn, có thể chỉ ra một khoảng|
|**--destination-port** [!] port[:port]| Xác định port đích, có thể chỉ ra một khoảng|
|**-tcp-flags** [!] mask comp| Xác định cờ của gói tin, có thể là SYN ACK FIN RST URG PSH ALL NONE|
|**[!] --syn**|Match các gói tin mà được set cờ SYN. Gói tin này được yêu cầu để khởi tạo kết nối tcp. Ví dụ, để chặn các gói tin khởi tạo kết nối đi vào, nhưng các gói tin đi ra vẫn hoạt động được. Lệnh này tương đương với lệnh **--tcp-flags SYN,RST,ACK,FIN SYN**. Nếu có dấu **!** thì có nghĩa là phủ định lại câu lệnh đó|
|**--tcp-option** [!] number| Match trường TCP option|
|**--mss** value[:value]| Match gói tin TCP SYN hoặc SYN/ACK với giá trị MSS (có thể nằm trong khoảng), để điều khiển kích thước tối đa của gói tin cho kết nối này|

###1.7.1 Ví dụ: 
```sh
iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -s $NET -j DROP
```

Một gói tin mang tcp flag SYN và FIN cùng một lượt không thể là một gói tin bình thường và hợp lệ. SYN-FIN chỉ thường thấy ở các thao tác rà cổng (port scan) hoặc được dùng với ý định không trong sáng. Gói tin ở dạng này nên loại trừ trước khi đi sâu vào hệ thống.


```sh
iptables -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -s $NET -j DROP
```

Một gói tin mang tcp flag FIN và RST cùng một lượt cũng có thể được xem bất hợp lệ. FIN flag trong một gói tin hợp lệ dùng để thông báo đầu bên kia dòng tin được chấm dứt để xuất truy cập được kết thúc đúng quy cách. Trong khi đó, RST flag dùng để "xé" ngang một xuất truy cập bất chợt. Trường hợp FIN và RST cùng trong một gói tin là điều bất thường và không nên tiếp nhận. 


##1.8 udp
Sử dụng với giao thức udp

|Command|Ý nghĩa|
|:---:|:---:|
| **--source-port** [!] port[:port]| Xác định một hoặc một dãy các port nguồn|
| **--destination-port** [!] port[:port]|Xác định một hoặc một dãy các port đích|



##1.9 icmp
Sử dụng với giao thức icmp. `-p icmp`

|Command|Ý nghĩa|
|:---:|:---:|
| **--icmp-type** [!] typename| Kiểu gói tin ICMP|

##1.10 iprange
Match một dãy các địa chỉ ip

|Command|Ý nghĩa|
|:---:|:---:|
| [!] **--src-range** ip-ip| Match dãy địa chỉ ip nguồn|
| [!] **--dst-range** ip-ip| Match dãy địa chỉ ip đích|


##1.11 length:
Match chiều dài gói tin

|Command|Ý nghĩa|
|:---:|:---:|
|**--length** [!] length[:length]| Match chiều dài gói tin, có thể đặt theo khoảng|

Theo RFC 793, SYN packet không mang theo "payload" (dữ liệu) và nếu các hệ thống ứng dụng đúng theo RFC 793 thì SYN packet chỉ có chiều dài tối đa là ở khoảng 40 đến 60 bytes nếu bao gồm các tcp options. Dựa trên quy định này (hầu hết các ứng dụng trên mọi hệ điều hành đều tuân thủ theo quy định của RFC 793), ví dụ: 

```sh
iptables -A INPUT -i $IF -p tcp --syn -s $NET --sport $HI_PORTS -d $IP --dport $port -m state --state NEW -m length --length 40:60 -j ACCEPT
```

Điều cần nói ở đây là giá trị -m length --length 40:60 ấn định chiều dài của gói tin SYN của giao thức TCP được firewall chúng ta tiếp nhận. Như đã đề cập ở trên, theo đúng quy định, gói SYN không mang dữ liệu cho nên kích thước của chúng không thể (và không nên) lớn hơn 40:60. Luật trên áp đặt một quy định rất khắc khe để loại trừ các gói SYN lại mang dữ liệu (và đặc biệt mang dữ liệu với kích thước lớn). Theo tôi thấy, những gói tin này rất hiếm thấy ngoại trừ trường hợp cố tình tạo ra hoặc thỉnh thoảng có dăm ba gói "lạc loài" ở đâu vào từ một hệ điều hành nào đó không ứng dụng đúng quy cách. Xử dụng luật này hay không là tùy mức khắc khe của bạn. Cách tốt nhất trước khi dùng, bạn nên thử capture các gói SYN cho suốt một ngày (hoặc nhiều) và mang về phân tích xem có bao nhiêu gói SYN thuộc dạng không cho phép, có bao nhiêu gói tin được xếp loại vào nhóm có chiều dài 40:60 bytes và từ đó mới đi đến quyết định cuối cùng. 


##1.12 mport
Tương tự multiport, match các port nguồn và đích. Được sử dụng với **-p tcp** hoặc **-p udp**.

|Command|Ý nghĩa|
|:---:|:---:|
| **--source-ports** port[,port[,port...]]| Match các giá trị port nguồn|
| **--destination-ports** port[,port[,port...]]|Match các giá trị port đích.
| **--ports** port[,port[,port...]]| Match các giá trị port, Lưu ý là so sánh cả 2 giá trị port nguồn và port đích.|

##1.13 multiport
Có thể Match số lượng lớn các cổng nguồn và đích. Có thể lên đến 15 cổng. port range (port:port) được tính như là 2 cổng. Được sử dụng với **-p tcp** hoặc **-p udp**.

|Command|Ý nghĩa|
|:---:|:---:|
|**--sport** *< port, port >*| Match các giá trị port nguồn|
|**--dport** *< port, port >*| Match các giá trị port đích.|
|**--port** *< port, port >*| Mach các giá trị port (không phân biệt nguồn hay đích).|

##1.14 mac
Match địa chỉ mac nguồn

|Command|Ý nghĩa|
|:---:|:---:|
|**--mac-source** *address* | Match địa chỉ mac nguồn. Nó có dạng là XX:XX:XX:XX:XX:XX. Chú ý, chỉ có tác dụng với thiết bị Ethernet và chain PREROUTING, FORWARD, INPUT|

##1.15 tcpmss
Match giá trị MSS (Maximum segment size) trong gói tin TCP header. Bạn chỉ có thể sử dụng với gói tin SYN hoặc SYN/ACT, kể từ lúc MSS đàm phán trong quá trình bắt tay 3 bước.

|Command|Ý nghĩa|
|:---:|:---:|
|[!] **--mss** value[:value]"|Match giá trị TCP MSS, có thể là một giá trị hoặc một khoảng giá trị|


##1.16 tos
Match 8 bits trong trường Type of Service của gói tin IP datagra header.

|Command|Ý nghĩa|
|:---:|:---:|
|[!] **--tos** value[/mask ]| Match giá trị tos
|[!] **--tos** symbol | Match TOS field (IPv4 only) by symbol|

Accepted symbolic names for value are:
- (0x10) 16 Minimize-Delay
- (0x08)  8 Maximize-Throughput
- (0x04)  4 Maximize-Reliability
- (0x02)  2 Minimize-Cost
- (0x00)  0 Normal-Service


##1.17 ttl
Matches trường ttl trong gói tin ip datagram.

|Command|Ý nghĩa|
|:---:|:---:|
| **--ttl-eq** ttl| Match giá trị TTL|
| **--ttl-gt** ttl| match TTL lớn hơn giá trị ttl mình cung cấp.|
| **--ttl-lt** ttl| Match TTL nhỏ hơn giá trị ttl mình cung cấp|


#2. Target Extensions

#Tài liệu tham khảo
http://linux.die.net/man/8/iptables

http://www.hvaonline.net/hvaonline/posts/list/0/105.hva

http://www.hvaonline.net/hvaonline/posts/list/135.hva