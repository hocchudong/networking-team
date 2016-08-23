# Macvlan vs Ipvlan
# Mục lục
<h3><a href="#macvlan">1. Macvlan</a></h3>
<h3><a href="#ipvlan">2. Ipvlan</a></h3>
<ul>
    <li><a href="#ipvlan-con">2.1. Ipvlan</a></li>
    <li><a href="#ipvlan-modes">2.2. Ipvlan modes</a></li>
    <li><a href="#cfg">2.3. Cấu hình Ipvlan trên linux</a></li>
</ul>
<h3><a href="#vs">3. Macvlan vs Ipvlan</a></h3>
<h3><a href="#ref">4. Tham khảo</a></h3>

---

<h2><a name="macvlan">1. Macvlan</a></h2>
<div>
    Macvlan cho phép cấu hình sub-interfaces (hay còn gọi là slave devices) trên một Ethernet interface vật lý (còn gọi là upper device), mỗi sub-interfaces này có địa chỉ MAC riêng và do đó có địa chỉ IP riêng. Các ứng dụng, VM và các containers có thể kết nối với một sub-interface nhất định để kết nối trực tiếp với mạng vật lý, sử dụng địa chỉ MAC và địa chỉ IP riêng của chúng.
    <br><br>
    <img src="http://hicu.be/wp-content/uploads/2016/03/linux-macvlan-1.png">
    <br><br>
    Mavvlan là giải pháp cho phép kết nối các VMs và các containers tới mạng vật lý, nhưng nó có hạn chế riêng:
    <ul>
        <li>Switch mà host kết nối tới có thể có policy hạn chế số lượng địa chỉ MAC trên một port vật lý.</li>
        <li>Nhiều card mạng có sự hạn chế về số lượng địa chỉ MAC hỗ trợ trên phần cứng. Vượt quá số lượng cho phép này sẽ làm ảnh hưởng tới hiệu năng của hệ thống.</li>
        <li>Chuẩn wifi IEEE 802.11 không muốn nhiều địa chỉ MAC trên một client. Điều đó có nghĩa là các macvlan sub-interfaces sẽ bị chặn bởi wireless interface driver hoặc Access Point. </li>
    </ul>
</div>
<h2><a name="ipvlan">2. Ipvlan</a></h2>
<ul>
    <li><h3><a name="ipvlan-con">2.1. Ipvlan</a></h3>
    Ipvlan khá giống so với macvlan, tuy nhiên nó có điểm khác so với macvlan là không gán địa chỉ MAC riêng cho các sub-interfaces. Các sub-interfaces chia sẻ chung địa chỉ MAC với parent interfaces (card vật lý trên đó tạo các sub-interfaces), nhưng có địa chỉ IP riêng.
    <br><br>
    <img src="http://hicu.be/wp-content/uploads/2016/03/linux-ipvlan.png">
    <br><br>
    Do các VMs hoặc các containers trên một parent interface sử dụng chung địa chỉ MAC, ipvlan có một số hạn chế sau:
    <ul>
        <li>Chia sẻ chung địa chỉ MAC có thể ảnh hưởng tới tiến trình DHCP. Nếu các VMs hoặc các containers sử dụng DHCp để yêu cầu cấu hình mạng, hãy đảm bảo chúng có ClientID duy nhất trong DHCP request và đảm bảo DHCP server gán địa chỉ IP dựa trên ClientID chứ không phải địa chỉ MAC</li>
        <li>Việc tự động cấu hình các địa chỉ IPv6 (định dạng EUI-64) được thực hiện dựa trên địa chỉ MAC. Tất cả các VMs hoặc các containers chia sẻ chung parent interface sẽ tự động tạo ra cùng một địa chỉ IPv6 cho chúng. Đảm bảo rằng các VMs hoặc các containers sử dụng địa chỉ Ipv6 tĩnh hoặc địa chỉ IPv6 riêng và ngắt kích hoạt SLAAC (Stateless Address Autoconfiguration - các client sẽ lắng nghe bản tin ICMPv6 Router Advertisement (RA) được gửi theo định kỳ từ router trên liên kết cục bộ, và lấy ra Link Prefix từ bản tin này kết hợp với địa chỉ MAC của nó ở định dạng EUI-64 để tạo ra địa chỉ IPv6 của riêng mình, thay vì xin cấp IP theo giao thức DHCPv6 - Stateful DHCP).</li>
    </ul>
    </li>
    <li><h3><a name="ipvlan-modes">2.2. Ipvlan modes</a></h3>
    Ipvlan có hai chế độ hoạt động. Trong cùng 1 thời điểm chỉ có thể sử dụng một trong hai mode cho một parent interface. Tất cả cả các sub-interfaces được vận hành trong mode đã được lựa chọn.
    <h4>Ipvlan L2</h4>
    <div>
    Ipvlan L2 hay Layer 2 mode tương tự với chế độ macvlan bridge mode.
    <br><br>
    <img src="http://hicu.be/wp-content/uploads/2016/03/linux-ipvlan-l2-mode.png">
    <br><br>
    Parent interface được coi như một switch giữa các sub-interfaces và parent interface. Tất cả các VMs hoặc containers kết nối tới cùng một parent Ipvlan interface và cùng một subnet có thể giao tiếp với nhau trực tiếp thông qua parent interface. Lưu lượng tới subnet khác gửi ra ngoài thông qua parent interface tới default gateway (router vật lý). Ipvlan chế độ L2 mode sẽ phân tán miền broadcasts/multicasts tới tất cả các sub-interfaces.
    </div>
    <h4>Ipvlan L3</h4>
    <div>
        Ipvlan L2 được coi coi như bridge hay switch giữa các sub-interfaces và parent interface. Tương tự như vậy, Ipvlan L3 hay Layer 3 mode được coi như thiết bị lớp 3 (như router) giữa các sub-interfaces và parent interfaces.
        <br><br>
        <img src="http://hicu.be/wp-content/uploads/2016/03/linux-ipvlan-l3-mode-1.png">
        <br><br>
        Ipvlan L3 mode định tuyến các gói tin giữa tất cả các sub-interfaces, do đó cung cấp đầy đủ kết nối lớp 3. Mỗi sub-interface phải được cấu hình với một subnet khác nhau. Ví dụ: 2 sub-interfaces không được cấu hình chung subnet 10.10.40.0/24.
        <br>
        Do miền broadcast bị hạn chế tới Layer 2 domain, dó đó các gói tin không thể đia từ một sub-interface tới sub-interface khác. Ipvlan L3 mode không hỗ trợ multicast.
        <br>Ipvlan L3 mode không hỗ trợ các giao thức định tuyến, dó đó nó không thông báo cho router vật lý về các subnet mà nó kết nối tới. Do đó ta cần cấu hình định tuyến tĩnh trên router vật lý trỏ tới card vật lý của host đối với các subnets trên các sub-interfaces.
        <br>
        <i><b>Chú ý: </b>Ipvlan L3 mode được  coi như một router - nó forward các gói tin IP giữa các subnet, tuy nhiên nó không làm giảm giá trị TTL ấn định cho gói tin đi qua nó. Do đó ta sẽ không thấy được Ipvlan "router" trên đường đi của gói tin khi kiểm tra bằng lệnh <b>traceroute.</b></i>
    </div>
    </li>

    <li><h3><a name="cfg">2.3. Cấu hình Ipvlan trên linux</a></h3>
        <h4>IPVLAN L2 MODE</h4>
        <div>
    <pre>
        <code>
  +=============================================================+
  |  Host: host1                                                |
  |                                                             |
  |   +----------------------+      +----------------------+    |
  |   |   NS:ns0             |      |  NS:ns1              |    |
  |   |                      |      |                      |    |
  |   |                      |      |                      |    |
  |   |        ipvl0         |      |         ipvl1        |    |
  |   +----------#-----------+      +-----------#----------+    |
  |              #                              #               |
  |              ################################               |
  |                              # eth0                         |
  +==============================#==============================+
        </code>
    </pre>
        Tạo hai network namespace <b>ns0</b> và <b>ns1</b>, tạo hai ipvlan sub-interfaces <b>ipvl0</b> và <b>ipvl1</b> rồi gán vào lần lượt hai namespace trên, ping thử giữa hai sub-interfaces này.        
    <pre>
        <code>
# add the namespaces
ip netns add ns0
ip netns add ns1
 
# create the macvlan link attaching it to the parent host eth0
ip link add ipvl0 link eth0 type ipvlan 
ip link add ipvl1 link eth0 type ipvlan 
 
# move the new interface ipvl0/ipvl1 to the new namespace
ip link set ipvl0 netns ns0
ip link set ipvl1 netns ns1
 
# bring the two interfaces up
ip netns exec ns0 ip link set dev ipvl0 up
ip netns exec ns1 ip link set dev ipvl1 up
 
# set ip addresses
ip netns exec ns0 ifconfig ipvl0 172.16.69.200/24 up
ip netns exec ns1 ifconfig ipvl1 172.16.69.201/24 up
 
# ping from one ns to another
ip netns exec ns0 ping 172.16.69.201 -c 4
        </code>
    </pre>
    Kết quả ping thành công tương tự như sau:
    <pre>
        <code>
PING 172.16.69.201 (172.16.69.201) 56(84) bytes of data.
64 bytes from 172.16.69.201: icmp_seq=1 ttl=64 time=0.146 ms
64 bytes from 172.16.69.201: icmp_seq=2 ttl=64 time=0.110 ms
64 bytes from 172.16.69.201: icmp_seq=3 ttl=64 time=0.120 ms
64 bytes from 172.16.69.201: icmp_seq=4 ttl=64 time=0.120 ms

--- 172.16.69.201 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3004ms
rtt min/avg/max/mdev = 0.110/0.124/0.146/0.013 ms
        </code>
    </pre>
    Ping thử từ ipvl0 sub-interface vào parent interface (eth0 - 172.16.69.176):
<pre>
    <code>
PING 172.16.69.176 (172.16.69.176) 56(84) bytes of data.

--- 172.16.69.176 ping statistics ---
4 packets transmitted, 0 received, 100% packet loss, time 3009ms
    </code>
</pre>
    Kết quả ping thất bại do kernel linux đã lọc ngăn không cho truyền thông giữa ipvlan sub-interfaces và parent interface (vì mục đích cô lập).
        </div>
    </li>

</ul>
<h2><a name="vs">3. Macvlan vs Ipvlan</a></h2>
<div>
    <ul>
        <li>Sử dụng ipvlan khi:
        <ul>
            <li>Parent interface là card wireles</li>
            <li>Gặp vấn đề về hạn chế số lượng địa chỉ MAC trên card mạng vật lý</li>
            <li>Gặp vấn đề về việc hạn chế số lượng MAC address của switch trên một port vì lý do bảo mật (Port Security)</li>
        </ul>
        </li>
        <li>
            Sử dụng Macvlan khi:
            <ul>
                <li>Sử dụng trong hầu hết các trường hợp còn lại, đặc biệt là khi hầu hết các DHCP server đều cấp phát IP cho client theo địa chỉ MAC chứ không phải ClientID, điều này Ipvlan không thể đáp ứng được.</li>
            </ul>
        </li>
    </ul>
</div>

<h2><a name="ref">4. Tham khảo</a></h2>
[1] - <a href="https://www.kernel.org/doc/Documentation/networking/ipvlan.txt">https://www.kernel.org/doc/Documentation/networking/ipvlan.txt</a>
<br>
[2] - <a href="http://networkstatic.net/configuring-macvlan-ipvlan-linux-networking/">http://networkstatic.net/configuring-macvlan-ipvlan-linux-networking/</a>
<br>
[3] - <a href="http://hicu.be/macvlan-vs-ipvlan">http://hicu.be/macvlan-vs-ipvlan</a>