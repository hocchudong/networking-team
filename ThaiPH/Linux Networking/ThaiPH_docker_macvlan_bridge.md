# Docker Networking: macvlan bridge
# Mục lục
<h3><a href="#purpose">1. Mục đích bài lab</a></h3>
<h3><a href="#nwtypes">2. Phân loại network trong Docker</a></h3>
<h3><a href="#macvlan">3. Lab tính năng macvlan bridge trong docker</a></h3>
<ul>
    <li><a href="#topo">3.1. Topology</a></li>
    <li><a href="#requirement">3.2. Yêu cầu</a></li>
    <li><a href="#cfg">3.3. Cài đặt và cấu hình</a></li>
</ul>
<h3><a href="#ref">4. Tham khảo</a></h3>

---

<h2><a name="purpose">1. Mục đích bài lab</a></h2>
<div>
    Macvlan được sử dụng để tạo kết nối mạng cho các container sử dụng công nghệ ảo hóa LXC hoặc Docker. Bài lab này là bài lab cơ bản để thử nghiệm macvlan driver với chế độ bridge (một trong 4 chế độ hoạt động của macvlan) trên Docker. 
    <br>
    <i>Ghi chú: Docker là nền tảng ảo hóa lấy ý tưởng từ LXC (Linux Container), mục đích là để triển khai các ứng dụng trong một <b>container</b> cung cấp đầy đủ thư viện để chạy ứng dụng, sử dụng chung kernel với hệ điều hành chủ, giảm overhead, dễ dàng, thuận tiện khi triển khai, nâng cấp, hủy bỏ,... ứng dụng so với khi triển khai ứng dụng trên VM hay LXC. </i> 
</div>

<h2><a name="nwtypes">2. Phân loại network trong Docker</a></h2>
<div>
    Docker cung cấp các tùy chọn kết nối mạng tương tự như các nền tảng ảo hóa khác như các hypervisor của VMWare, Hyper-V, KVM, Xen, Virtualbox,... Tuy nhiên, cách tiếp cận của Docker có một chút khác biệt do các network driver mà nó cung cấp, gây khó hiểu đối với những người dùng mới đã quen thuộc với các khái niệm network trong các nền tảng ảo hóa khác. Bảng sau sẽ mô tả các chế độ network tương ứng với network driver mà docker cung cấp để tạo kết nối cho các container:
    <table>
        <tr>
            <td>Các khái niệm trong ảo hóa mạng thông thường</td>
            <td>Docker network driver</td>
        </tr>
        <tr>
            <td>NAT Network</td>
            <td>bridge</td>
        </tr>
        <tr>
            <td>Bridge</td>
            <td>macvlan / ipvlan</td>
        </tr>
        <tr>
            <td>Private/Host Only</td>
            <td>bridge</td>
        </tr>
        <tr>
            <td>Overlay Network / VXLAN</td>
            <td>overlay</td>
        </tr>
    </table>
</div>
<h2><a name="macvlan">3. Lab tính năng macvlan bridge trong docker</a></h2>
<ul>
    <li><h3><a name="topo">3.1. Topology</a></h3>
<br>
<img src="http://i.imgur.com/RENOOzz.png">
<br>
    </li>
    <li><h3><a name="requirement">3.2. Yêu cầu</a></h3>
    <ul>
        <li>Docker host cài đặt Ubuntu 14.04, phiên bản kernel yêu cầu thấp nhất là 3.9 (trong bài lab bản Ubuntu đã update kernel lên 4.x.x)</li>
        <li>Docker host cài đặt docker phiên bản thấp nhất là 1.11 hoặc mới hơn(thời điểm bài lab thực hiện đang là phiên bản 1.12)</li>
        <li>Docker host (lab trên VMware Workstation) có 1 card kết nối internet (chế độ bridge hoặc NAT), trong bài lab sử dụng card NAT dải <code>172.16.69.0/24</code>.</li>
    </ul>
    </li>
    <li><h3><a name="cfg">3.3. Cài đặt và cấu hình</a></h3>
    <ul>

        <li><h4>Tạo macvlan network. </h4>Trong khi macvlan có 4 chế độ (VEPA, bridge, private, passthrough), thì Docker macvlan driver chỉ hỗ trợ macvlan bridge mode. Tiến hành tạo <code>macvlan network</code> mới tên là <b>macvlan0</b> sử dụng lệnh sau:
<pre>
    <code>
docker network create -d macvlan --subnet=172.16.69.0/24 --gateway=172.16.69.1 --ip-range=172.16.69.192/26 -o parent=eth0 macvlan0        
    </code>
</pre>
        Giải thích các tùy chọn:
        <ul>
            <li><b>-d</b>: tùy chọn docker network driver (macvlan, bridge, overlay).</li>
            <li><b>--subnet</b> và <b>--gateway</b>: subnet và gateway này trùng với subnet network và cấu hình gateway của <b>lower device</b> (ở đây là eth0) được chỉ định bởi tùy chọn <b>parent.</b></li>
            <li><b>--ip-range</b>: dải địa chỉ cấp cho các container. Việc cấp IP cho các container không do external DHCP cung cấp mà nhờ <b>IPAM</b> driver đã cung cấp sẵn khi cài Docker.</li>
        </ul>
        Các container sử dụng cấu hình DNS của Docker host nên không cần cấu hình tham số này cho macvlan network.
        <br>
        Xác nhận macvlan network đã tạo:
<pre>
    <code>
# liet ke danh sach cac macvlan network
docker network ls | grep macvlan
# ket qua tuong tu nhu sau
8e93e9a79387        macvlan0            macvlan             local
    </code>
</pre>
        Xem chi tiết thông tin macvlan network <b>macvlan0</b>:
<pre>
    <code>
# lenh kiem tra
docker network inspect macvlan0
# ket qua tra ve tuong tu nhu sau
[
    {
        "Name": "macvlan0",
        "Id": "8e93e9a793879e2da2c22c9b2e7c10063e0daf3d443a23597b71e3170f59c77c",
        "Scope": "local",
        "Driver": "macvlan",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.16.69.0/24",
                    "IPRange": "172.16.69.192/26",
                    "Gateway": "172.16.69.1"
                }
            ]
        },
        "Internal": false,
        "Containers": {},
        "Options": {
            "parent": "eth0"
        },
        "Labels": {}
    }
]
    </code>
</pre>

        </li>

        <li>
            Tạo container mới tên <b>alpine1</b> thuộc dải <b>macvlan0</b>:
<pre>
    <code>
docker run --net=macvlan0 -itd --name='alpine1'  alpine /bin/sh
    </code>
</pre>
            Kiểm tra địa chỉ ip của alpine1:
<pre>
    <code>
docker exec -ti alpine1 ip a
# ket qua tuong tu nhu sau
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
5: eth0@if2: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UNKNOWN
    link/ether 02:42:ac:10:45:c0 brd ff:ff:ff:ff:ff:ff
    inet 172.16.69.192/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe10:45c0/64 scope link
       valid_lft forever preferred_lft forever
    </code>
</pre>
        Ta thấy địa chỉ đầu tiên trong dải IP mà <b>macvlan0</b> thiết lập được cấp cho container này. Kiểm tra thông tin network <b>macvlan0</b> để xác nhận container đã được gắn vào macvlan network này:
<pre>
    <code>
docker network inspect macvlan0
# ket qua tuong tu nhu sau
[
    {
        "Name": "macvlan0",
        "Id": "8e93e9a793879e2da2c22c9b2e7c10063e0daf3d443a23597b71e3170f59c77c",
        "Scope": "local",
        "Driver": "macvlan",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.16.69.0/24",
                    "IPRange": "172.16.69.192/26",
                    "Gateway": "172.16.69.1"
                }
            ]
        },
        "Internal": false,
        "Containers": {
            "cf80975deb30c94ed65559e7e93fdd4de32263f98bbf6f7a9f07b22938e6fa2f": {
                "Name": "alpine1",
                "EndpointID": "ff6d54bdc31b56a608716c6883f10b8d45cd12c173ba94869d6d3fba9dee71ad",
                "MacAddress": "02:42:ac:10:45:c0",
                "IPv4Address": "172.16.69.192/24",
                "IPv6Address": ""
            }
        },
        "Options": {
            "parent": "eth0"
        },
        "Labels": {}
    }
]
    </code>
</pre>

        Tiến hành ping thử ra gateway và ping ra internet kiểm tra kết nối:
<pre>
    <code>
# ping ra gateway
docker exec -ti alpine1 ping 172.16.69.1 -c 3
# ket qua tuong tu nhu sau
PING 172.16.69.1 (172.16.69.1): 56 data bytes
64 bytes from 172.16.69.1: seq=0 ttl=128 time=0.759 ms
64 bytes from 172.16.69.1: seq=1 ttl=128 time=0.593 ms
64 bytes from 172.16.69.1: seq=2 ttl=128 time=0.868 ms

--- 172.16.69.1 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.593/0.740/0.868 ms

# ping ra internet
docker exec -ti alpine1 ping google.com -c 3
# ket qua tuong tu nhu sau
PING google.com (216.58.199.14): 56 data bytes
64 bytes from 216.58.199.14: seq=0 ttl=128 time=85.404 ms
64 bytes from 216.58.199.14: seq=2 ttl=128 time=78.378 ms

--- google.com ping statistics ---
3 packets transmitted, 2 packets received, 33% packet loss
round-trip min/avg/max = 78.378/81.891/85.404 ms
    </code>
</pre>
Ping thử tới <b>parent interface</b> của network <b>macvlan0</b>, ta thấy kết quả ping thất bại:
<pre>
    <code>
# kiem tra dia chi cua parent interface - eth0
ip a | grep eth0
# dia chi eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 172.16.69.176/24 brd 172.16.69.255 scope global eth0

# ping toi eth0
docker exec -ti alpine1 ping 172.16.69.176 -c 3
# ket qua tuong tu nhu sau
PING 172.16.69.176 (172.16.69.176): 56 data bytes

--- 172.16.69.176 ping statistics ---
3 packets transmitted, 0 packets received, 100% packet loss
    </code>
</pre>
<i><b>Chú ý: </b>đối với cả hai chế độ <b>macvlan</b> và <b>ipvlan</b>, ta đều không thê ping hay truyền thông với các địa chỉ thuộc default namespace (hay root namespace của hệ điều hành chủ, nơi các card mạng vật lý hoạt động). Ví dụ như ở đây ta ping giữa container <b>alpine1</b> tới card eth0 của docker host bị thất bại. Lưu lượng đó đã bị lọc ngầm định bởi kernel module nhằm cung cấp khả năng bảo mật và cô lập về network.</i>
        </li>

        <li>
            Tạo thêm 1 container <b>alpine2</b> và ping tới container <b>alpine1</b> kiểm tra kết nối:
<pre>
    <code>
# tao container
docker run --net=macvlan0 -itd --name='alpine2'  alpine /bin/sh

# kiem tra ip
docker exec -ti alpine2 ip a
# dia chi ip cua alpine2
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
6: eth0@if2: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UNKNOWN
    link/ether 02:42:ac:10:45:c1 brd ff:ff:ff:ff:ff:ff
    inet 172.16.69.193/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe10:45c1/64 scope link
       valid_lft forever preferred_lft forever

# ping toi alpine1 kiem tra ket noi
docker exec -ti alpine2 ping 172.16.69.193 -c 3
# ket qua ping 
PING 172.16.69.193 (172.16.69.193): 56 data bytes
64 bytes from 172.16.69.193: seq=0 ttl=64 time=0.206 ms
64 bytes from 172.16.69.193: seq=1 ttl=64 time=0.150 ms
64 bytes from 172.16.69.193: seq=2 ttl=64 time=0.433 ms

--- 172.16.69.193 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.150/0.263/0.433 ms
    </code>
</pre>
Kết quả ping thành công.
        </li>
    </ul>
    </li>

</ul>
<h2><a name="ref">4. Tham khảo</a></h2>
[1] - <a href="http://hicu.be/docker-networking-macvlan-bridge-mode-configuration">http://hicu.be/docker-networking-macvlan-bridge-mode-configuration</a>
<br>
[2] - <a href="https://github.com/docker/docker/blob/master/experimental/vlan-networks.md">https://github.com/docker/docker/blob/master/experimental/vlan-networks.md</a>

