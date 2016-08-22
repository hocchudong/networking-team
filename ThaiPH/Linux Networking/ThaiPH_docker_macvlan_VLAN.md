# Docker Networking: macvlan với VLAN 
# Mục lục 
<h3><a href="#topo">1. Topology</a></h3>
<h3><a href="#cfg">2. Cài đặt và cấu hình</a></h3>
<ul>
    <li><a href="#host_net">2.1. Cài đặt OpenvSwitch, KVM và cấu hình libvirt network</a></li>
    <li><a href="#docker_host_cfg">2.2. Cấu hình các Docker host</a></li>
    <li><a href="#container_test">2.3. Kiểm tra kết nối</a></li>
</ul>
<h3><a href="#ref">3. Tham khảo</a></h3>

---

<h2><a name="topo">1. Topology</a></h2>
<div>
    <img src="http://i.imgur.com/nUq4mzx.png">
    <br><br>
    Chuẩn bị:
    <ul>
        <li>Một máy <b>HOST</b> chạy ubuntu desktop 14.04, cài OpenvSwitch + KVM + Virt Manager</li>
        <li>Tạo hai KVM docker host trên máy <b>HOST</b> chạy ubuntu desktop 14.04, trên mỗi máy cài đặt sẵn <b>docker</b> (thời điểm bài lab thực hiện đang cài phiên bản 1.12) và <b>vlan</b> driver.</li>
    </ul>
</div>
<h2><a name="cfg">2. Cài đặt và cấu hình</a></h2>
<ul>
    <li><h3><a name="host_net">2.1. Cài đặt OpenvSwitch, KVM và cấu hình libvirt network</a></h3>
    <div>
    Tất cả các thao tác sau thực hiện trên máy <b>HOST</b>
    <h4>Cài đặt KVM và virt-manager</h4>  
    <div>
    Cài đặt các gói sau:
    <pre>
        <code>
    sudo apt-get install ubuntu-virt-server python-vm-builder kvm-ipxe bridge-utils libguestfs-tools qemu-kvm libvirt-bin ubuntu-vm-builder
        </code>
    </pre>
    Thực hiện đưa người dùng hiện tại vào nhóm <b>libvirtd</b>
    <pre>
        <code>
    sudo adduser `id -un` libvirtd
        </code>
    </pre>
    Cài đặt thêm công cụ <b>virt-manager</b> để quản lý các máy ảo giao diện đồ họa:
    <pre>
        <code>
    sudo apt-get install virt-manager
        </code>
    </pre>
    </div> 

    <h4>Cài đặt OpenvSwitch</h4>   
    <div>
    Cài đặt các gói sau:
    <pre>
        <code>
    sudo apt-get install -y openvswitch-switch openvswitch-datapath-dkms
        </code>
    </pre>
    Tạo bridge <code>br-int</code>:
    <pre>
        <code>
    sudo ovs-vsctl add-br br-int
        </code>
    </pre>
    Tạo libvirt network tương ứng với bridge <code>br-int</code>, định nghĩa trong một file *xml. Thực hiện tạo file cấu hình libvirt network: <code>vi ovs-net.xml</code>. Nội dung file <code>ovs-net.xml</code> như sau:
    <pre>
        <code>
&lt;network&gt;
  &lt;name&gt;ovs-network&lt;/name&gt;
  &lt;forward mode='bridge'/&gt;
  &lt;bridge name='br-int'/&gt;
  &lt;virtualport type='openvswitch'/&gt;
  &lt;portgroup name='vlan-00' default='yes'&gt;
  &lt;/portgroup&gt;
  &lt;portgroup name='vlan-100'&gt;
    &lt;vlan&gt;
      &lt;tag id='100'/&gt;
    &lt;/vlan&gt;
  &lt;/portgroup&gt;
  &lt;portgroup name='vlan-200'&gt;
    &lt;vlan&gt;
      &lt;tag id='200'/&gt;
    &lt;/vlan&gt;
  &lt;/portgroup&gt;
  &lt;portgroup name='vlan-all'&gt;
    &lt;vlan trunk='yes'&gt;
      &lt;tag id='100'/&gt;
      &lt;tag id='200'/&gt;
    &lt;/vlan&gt;
  &lt;/portgroup&gt;
&lt;/network&gt;    
        </code>
    </pre>
    File cấu hình ở trên thực hiện cấu hình network <b>ovs-network</b> tương ứng với 3 port group trên bridge <b>br-int</b>, 1 group dành cho vlan 100 (tag=100), một port group dành cho vlan 200 (tag=200) và 1 port group là dành cho các kết nối trunking.
    <br>Lưu lại file cấu hình và áp dụng cấu hình network trên cho máy <b>HOST</b>
    <pre>
        <code>
virsh net-define ovs-net.xml
# khoi dong network <b>ovs-network</b> 
virsh net-start ovs-network
# tu dong cau hinh khi khoi dong lai
virsh net-autostart ovs-network
        </code>
    </pre>
    </div> 

    </div>
    </li>

    <li><h3><a name="docker_host_cfg">2.2. Cấu hình các Docker host</a></h3>
    <div>
        <h4>Cấu hình network cho các Docker host</h4>
        <div>
        Với mỗi docker host, ta tạo hai card mạng:
        <ul>
            <li>
            Một card gán vào network <b>ovs-network</b> đã tạo ở trên thuộc port group <b>vlan-all</b>, bài lab này chọn card <b>eth0</b>, nhằm mục đích tạo đường trunk giữa card này với bridge <b>br-int</b> cho phép lưu lượng từ 2 vlan 100 và 200 trên các sub-interfaces đi qua.
            </li>

            <li>
            Một card kết nối internet, bài lab này chọn card <b>eth1</b> chế độ <b>default</b> hay chính là chế độ <b>NAT</b> mặc định khi sử dụng libvirt network(có thể chọn chế độ khác chẳng hạn như macvlan chế độ bridge). Mục đích card này để kết nối với internet cho các docker host, cài đặt các gói phần mềm.
            </li>
        </ul>
        Điểm cần chú ý duy nhất ở đây là cấu hình kết nối card <b>eth0</b> của mỗi docker host kết nối vào port group <b>vlan-all</b> của network <b>ovs-network</b>. Để làm điều đó, trên máy <b>HOST</b> (host chứa 2 docker host), thực hiện chỉnh sửa cấu hình 2 docker host như sau (ở đây ví dụ cấu hình cho docker host 0, docker host 1 tương tự):
        <ul>
            <li>Mở file cấu hình máy ảo docker host 0, chú ý gõ chính xác tên máy ảo:
        <pre>
            <code>
virsh edit docker-host0
            </code>
        </pre>
            </li>
            <li>Chỉnh sửa lại trong section <code>&lt;interface&gt;</code> như sau:
        <pre>
            <code>
&lt;interface type='network'&gt;
  &lt;mac address='52:54:00:e4:38:8d'/&gt;
  &lt;<b>source network='ovs-network' portgroup='vlan-all'/</b>&gt;
  &lt;model type='virtio'/&gt;
  &lt;address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/&gt;
&lt;/interface&gt;
            </code>
        </pre>
            </li>
        </ul>
        Lưu lại các file cấu hình và bật hai máy ảo docker host lên, sau đó kiểm tra lại bằng lệnh sau để xác nhận đã cấu hình đúng:
        <pre>
            <code>
sudo ovs-vsctl show
            </code>
        </pre>
        Kết quả trả về sẽ tương tự như sau:
        <pre>
            <code>
2de13b1f-ec77-4488-ba92-5c4b0639757f
    Bridge br-int
        Port "vnet1"
            trunks: [100, 200]
            Interface "vnet1"
        Port br-int
            Interface br-int
                type: internal
        Port "vnet0"
            trunks: [100, 200]
            Interface "vnet0"
    ovs_version: "2.0.2"                
            </code>
        </pre>
        Nếu cấu hình thành công, ta sẽ thấy kết quả lệnh trên xuất hiện 2 port <b>vnet0</b> và <b>vnet1</b> trên bridge <b>br-int</b> cấu hình là port trunk với hai vlan 100 và 200. Chú ý, hai port <b>vnet0</b> và <b>vnet1</b> được gọi là các <b>tap interface</b> trên bridge <b>br-int</b> nơi mà các máy ảo gắn vào.
        </div>

        <h4>Cài đặt vlan driver</h4>
        Trên mỗi máy Docker host cài đặt vlan driver như sau:
        <div>
    <pre>
        <code>
sudo apt-get install vlan
# load kernel module
sudo modprobe 8021q
        </code>
    </pre>            
        </div>

        <h4>Tạo các vlan sub-interfaces</h4>
        <div>
        Trên mỗi máy docker host thực hiện tạo 2 VLAN sub-interfaces tag 100 và 200  trên card <b>eth0</b> tương ứng với 2 vlan đã cấu hình trên bridge <b>br-int</b>:
    <pre>
        <code>
sudo vconfig add eth0 100
sudo vconfig add eth0 200
# up 2 sub-interfaces
sudo ifconfig eth0.100 up
sudo ifconfig eth0.200 up
        </code>
    </pre>
        Kiểm tra 2 VLAN interfaces đã tạo:
    <pre>
        <code>
cat /proc/net/vlan/config
# ket qua tra ve tuong tu nhu sau
VLAN Dev name    | VLAN ID
Name-Type: VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD
eth0.100       | 100  | eth0
eth0.200       | 200  | eth0
        </code>
    </pre>
        </div>

        <h4>Tạo các macvlan network</h4>
        <div>
        <ul>
            <li><b>Docker host 0</b>
            <div>
                Tạo hai network <b>macvlan100</b> và <b>macvlan200</b> tương ứng với 2 vlan 100 và 200 và tương ứng với hai <b>parent interface</b> là <b>eth0.100</b> và <b>eth0.200</b>. Sau đó với mỗi macvlan network, tạo 2 container gắn vào để kiểm tra:
    <pre>
        <code>
# tao network <b>macvlan100</b> 
docker network  create  -d macvlan \
   --subnet=172.16.0.0/16 \
    --ip-range=172.16.1.0/24 \
    -o macvlan_mode=bridge \
    -o parent=eth0.100 macvlan100
# tao container gan vao network <b>macvlan100</b>
docker run --net=macvlan100 -itd --name macvlan100_1 alpine /bin/sh
docker run --net=macvlan100 -itd --name macvlan100_2 alpine /bin/sh

# tao network <b>macvlan200</b> 
docker network  create  -d macvlan \
   --subnet=10.10.0.0/16 \
    --ip-range=10.10.1.0/24 \
    -o macvlan_mode=bridge \
    -o parent=eth0.200 macvlan200
# tao container gan vao network <b>macvlan200</b>
docker run --net=macvlan200 -itd --name macvlan200_1 alpine /bin/sh
docker run --net=macvlan200 -itd --name macvlan200_2 alpine /bin/sh
        </code>
    </pre>
            </div>
            </li>

            <li><b>Docker host 1</b>
            <div>
                Tạo hai network <b>macvlan100</b> và <b>macvlan200</b> tương ứng với 2 vlan 100 và 200 và tương ứng với hai <b>parent interface</b> là <b>eth0.100</b> và <b>eth0.200</b>. Sau đó với mỗi macvlan network, tạo 2 container gắn vào để kiểm tra:
    <pre>
        <code>
# tao network <b>macvlan100</b> 
docker network  create  -d macvlan \
   --subnet=172.16.0.0/16 \
    --ip-range=172.16.2.0/24 \
    -o macvlan_mode=bridge \
    -o parent=eth0.100 macvlan100
# tao container gan vao network <b>macvlan100</b>
docker run --net=macvlan100 -itd --name macvlan100_3 alpine /bin/sh
docker run --net=macvlan100 -itd --name macvlan100_4 alpine /bin/sh

# tao network <b>macvlan200</b> 
docker network  create  -d macvlan \
   --subnet=10.10.0.0/16 \
    --ip-range=10.10.2.0/24 \
    -o macvlan_mode=bridge \
    -o parent=eth0.200 macvlan200
# tao container gan vao network <b>macvlan200</b>
docker run --net=macvlan200 -itd --name macvlan200_3 alpine /bin/sh
docker run --net=macvlan200 -itd --name macvlan200_4 alpine /bin/sh
        </code>
    </pre>
            </div>
            </li>
        </ul>
            
        </div>


    </div>

    </li>

    <li><h3><a name="container_test">2.3. Kiểm tra kết nối</a></h3>
    <div>
        <ul>
            <li><b>Docker host 0</b>
            <div>
                <ul>
                    <li>Kiểm tra network <b>macvlan100</b>
    <pre>
        <code>
docker network inspect macvlan100
# ket qua tra ve tuong tu nhu sau
[
    {
        "Name": "macvlan100",
        "Id": "c26fb15af7893fadd186208a2b9a81d560768fbb4e3919de23874b6b8e75160c",
        "Scope": "local",
        "Driver": "macvlan",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.16.0.0/16",
                    "IPRange": "172.16.1.0/24"
                }
            ]
        },
        "Internal": false,
        "Containers": {
            "1337cc4da1107b578db7abaef50b942a9d4c1213f9564345be9e9460be41f76c": {
                "Name": "macvlan100_1",
                "EndpointID": "e3bbabca2d458ddeeaabd89423cbe114c19cf8301585563f6d5804e1b781594e",
                "MacAddress": "02:42:ac:10:01:01",
                "IPv4Address": "172.16.1.1/16",
                "IPv6Address": ""
            },
            "bfe5b525ee256a6ea284e4efa242f86b0de149d91fc6eb56b9d89e089e445f1f": {
                "Name": "macvlan100_2",
                "EndpointID": "9c307d434f9596f8743196de7d2172a7baf61a9664744ca1da26b548a2b7b368",
                "MacAddress": "02:42:ac:10:01:02",
                "IPv4Address": "172.16.1.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "macvlan_mode": "bridge",
            "parent": "eth0.100"
        },
        "Labels": {}
    }
]
        </code>
    </pre>
                    </li>
                    <li>Kiểm tra network <b>macvlan200</b>
    <pre>
        <code>
docker network inspect macvlan200
# ket qua tra ve tuong tu nhu sau
[
    {
        "Name": "macvlan200",
        "Id": "92fd8a29eef5c37723069be59b2e0542cb452aab6a4caf5880afb00f1df068f3",
        "Scope": "local",
        "Driver": "macvlan",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "10.10.0.0/16",
                    "IPRange": "10.10.1.0/24"
                }
            ]
        },
        "Internal": false,
        "Containers": {
            "247be6b46b345164156da8206e69622b11ea337afd76fb331d67fbf55f29086a": {
                "Name": "macvlan200_2",
                "EndpointID": "95368917bcff5911a2e3a28baab922c0b53bfd533a3bb07c24d62fafa039c484",
                "MacAddress": "02:42:0a:0a:01:02",
                "IPv4Address": "10.10.1.2/16",
                "IPv6Address": ""
            },
            "3c2bcd3fba71ff55217ec37c5fa7910de258c88d4db1d931da603934b4eaa656": {
                "Name": "macvlan200_1",
                "EndpointID": "617df0163b546ae396cb3342c94266559f979b204bb73b4fc149c74c0a2e3578",
                "MacAddress": "02:42:0a:0a:01:01",
                "IPv4Address": "10.10.1.1/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "macvlan_mode": "bridge",
            "parent": "eth0.200"
        },
        "Labels": {}
    }
]
        </code>
    </pre>
                    </li>
                </ul>
            </div>
            </li>

            <li><b>Docker host 1</b>
            <div>
                <ul>
                    <li>Kiểm tra network <b>macvlan100</b>
    <pre>
        <code>
docker network inspect macvlan100
# ket qua tra ve tuong tu nhu sau
[
    {
        "Name": "macvlan100",
        "Id": "7bba398b5c359e55eebfc80f9817d7cee3f88bbde529984e701f7088405a5e77",
        "Scope": "local",
        "Driver": "macvlan",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.16.0.0/16",
                    "IPRange": "172.16.2.0/24"
                }
            ]
        },
        "Internal": false,
        "Containers": {
            "3815f06e573649143140659ad0fe84463b1a453367e66b5352424c9441c8f221": {
                "Name": "macvlan100_3",
                "EndpointID": "b8d3a25bdf6fb85393b1e8791ca26543f480c8706c1caf16a9a07d9b9b35d7e5",
                "MacAddress": "02:42:ac:10:02:01",
                "IPv4Address": "172.16.2.1/16",
                "IPv6Address": ""
            },
            "5abbcd73cd44db795c8002c7f39aee127c3cb2daa56de607c71d9834cc450945": {
                "Name": "macvlan100_4",
                "EndpointID": "520b2fa68e43febc09ef457c022e54d65a649f43f2c3c8aaf0b380b4ca96dbb1",
                "MacAddress": "02:42:ac:10:02:02",
                "IPv4Address": "172.16.2.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "macvlan_mode": "bridge",
            "parent": "eth0.100"
        },
        "Labels": {}
    }
]       
        </code>
    </pre>
                    </li>

                    <li>Kiểm tra network <b>macvlan200</b>
    <pre>
        <code>
docker network inspect macvlan200
# ket qua tra ve tuong tu nhu sau
[
    {
        "Name": "macvlan200",
        "Id": "e47292c791c2cad8597e162a45693ee4f33dd291d06792dc67727e80596c731d",
        "Scope": "local",
        "Driver": "macvlan",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "10.10.0.0/16",
                    "IPRange": "10.10.2.0/24"
                }
            ]
        },
        "Internal": false,
        "Containers": {
            "daac8f6303dedd0ddb5ac5d74fdb41521fff0a1b6d0dc64d51bc22c7b557d753": {
                "Name": "macvlan200_4",
                "EndpointID": "76819fbcf7f0786bcde33f8423fb540a745da3bcbc72e68bc451db883cf1e697",
                "MacAddress": "02:42:0a:0a:02:01",
                "IPv4Address": "10.10.2.1/16",
                "IPv6Address": ""
            },
            "f187d3ed05d2dc18ba0c5dc59db77118ad7fd61daa5a7672c4c2610256920c7b": {
                "Name": "macvlan200_3",
                "EndpointID": "6af0de31e5342b503d4d58073c4bcb034e85eac42af0d1c8b9e2af573f838919",
                "MacAddress": "02:42:0a:0a:02:02",
                "IPv4Address": "10.10.2.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "macvlan_mode": "bridge",
            "parent": "eth0.200"
        },
        "Labels": {}
    }
]       
        </code>
    </pre>
                    </li>
                </ul>
            </div>
            </li>

            <li>Kiểm tra kết nối 
            <ul>
                <li>Trên <b>Docker host 1</b> thực hiện ping thử giữa hai máy cùng vlan 100 hay cùng mạng <b>macvlan100</b>(<b>macvlan100_3</b> với địa chỉ <code>172.16.2.1/16</code>và <b>macvlan100_4</b> với địa chỉ <code>172.16.2.2/16</code>)
    <pre>
        <code>
docker exec -ti macvlan100_3 ping 172.16.2.2 -c 4

# ket qua tra ve tuong tu nhu sau
PING 172.16.2.2 (172.16.2.2): 56 data bytes
64 bytes from 172.16.2.2: seq=0 ttl=64 time=0.869 ms
64 bytes from 172.16.2.2: seq=1 ttl=64 time=0.090 ms
64 bytes from 172.16.2.2: seq=2 ttl=64 time=0.093 ms
64 bytes from 172.16.2.2: seq=3 ttl=64 time=0.090 ms

--- 172.16.2.2 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.090/0.285/0.869 ms
        </code>
    </pre>
                </li>

                <li>Kiểm tra kết nối giữa hai máy cùng vlan 200 trên 2 host, cụ thể thực hiện ping giữa container <b>macvlan200_3</b> trên <b>Docker host 1</b> với địa chỉ <code>10.10.2.2</code> tới container <b>macvlan200_1</b> trên <b>Docker host 0</b> với địa chỉ <code>10.10.1.1</code>
    <pre>
        <code>
docker exec -ti macvlan200_3 ping 10.10.1.1 -c 4

# ket qua tra ve se tuong tu nhu sau
PING 10.10.1.1 (10.10.1.1): 56 data bytes
64 bytes from 10.10.1.1: seq=0 ttl=64 time=2.351 ms
64 bytes from 10.10.1.1: seq=1 ttl=64 time=0.712 ms
64 bytes from 10.10.1.1: seq=2 ttl=64 time=1.065 ms
64 bytes from 10.10.1.1: seq=3 ttl=64 time=0.748 ms

--- 10.10.1.1 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.712/1.219/2.351 ms
        </code>
    </pre>
                </li>
            </ul>
            </li>

        </ul>

    </div>
    </li>
</ul>
<h2><a name="ref">3. Tham khảo</a></h2>
[1] - <a href="https://sreeninet.wordpress.com/2016/05/29/docker-macvlan-and-ipvlan-network-plugins/">https://sreeninet.wordpress.com/2016/05/29/docker-macvlan-and-ipvlan-network-plugins/</a>
<br>
[2] - <a href="http://blog.scottlowe.org/2013/05/28/vlan-trunking-to-guest-domains-with-open-vswitch/">http://blog.scottlowe.org/2013/05/28/vlan-trunking-to-guest-domains-with-open-vswitch/</a>

