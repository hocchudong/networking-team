# Kịch bản triển khai OpenStack cơ bản với OpenvSwitch
# Mục lục
<h3><a href="#pre">1. Yêu cầu</a></h3>
<h3><a href="#arch">2. Kiến trúc</a></h3>
<h3><a href="#flow">3. Packet flow</a></h3>
<h3><a href="#cfg">4. Cấu hình</a></h3>
<h3><a href="#verify">5. Xác nhận cấu hình và tạo network</a></h3>
<h3><a href="#ref">6. Tham khảo</a></h3>

---
<i>
    Kịch bản triển khai này cho phép các user không có đặc quyền được quản lý mạng ảo bên trong một project, bao gồm các thành phần sau:
    <ul>
        <li><b>Project (tenant) networks: </b> Cung cấp kết nối cho các instance trên một project. Các người dùng thông thường có thể quản lý các project network trong giới hạn mà người quản trị cấp cho họ. Project network có thể sử dụng VLAN, GRE hoặc VXLAN (trong bài này sử dụng VXLAN transport). Project neworks thông thường sử dụng các địa chỉ private IP và không thể kết nối ra mạng ngoài. Các địa chỉ IP trên project network được gọi là <b>fixed IP</b> addresses.</li>
        <li><b>External networks: </b>Cung cấp kết nối ra mạng ngoài hay internet, được tạo bởi người quản trị, tương tác với hạ tầng mạng vật lý. External network có thể sử dụng VLAN hoặc flat phụ thuộc vào hạ tầng mạng vật lý.</li>
        <li><b>Các routers: </b>cung cấp SNAT, DNAT và floating IP map với fixed IP để cung cấp kết nối mạng cho các instances.</li>
        <li><b>Các dịch vụ hỗ trợ: </b>Bao gồm DHCP và metadata.</li>
    </ul>
</i>

<h2><a name="pre">1. Yêu cầu</a></h2>
<div>
    Mô hình cài đặt gồm 3 node (controller + network + compute) hoặc 2 node (controller và network + compute), cài đặt OpenStack phiên bản Mitaka:
    <ul>
        <li>Controller node cần 1 card mạng <b>management</b></li>
        <li>Network node cần 4 card mạng: management, project tunnel networks, VLAN project networks, external. OpenvSwitch bridge <b>br-vlan</b> phải chứa 1 port trên VLAN interface và OpenvSwitch bridge <b>br-ex</b> chứa một port trên external interface.</li>
        <li>Compute node cần 3 card mạng: management, project tunnel network và VLAN project networks. OpenvSwitch bridge <b>br-vlan</b> phải chứa 1 port trên VLAN interface.</li>        
    </ul>
    Tuy nhiên ở bài viết này, chỉ sử dụng mô hình gồm 2 node:
    <ul>
        <li><b>Controller + Network: </b> node này làm nhiệm vụ của cả controller và network node.       
        </li>
        <li><b>Compute node</b></li>
    </ul>
    Cả hai node này đều cấu hình gồm 3 card mạng (không sử dụng VLAN interface cho project network):
    <ul>
        <li><b>Management: </b>dải 10.10.10.0/24</li>
        <li><b>Data: </b>dải 10.10.20.0/24</li>
        <li><b>External: </b>dải 172.16.69.0/24 (dải này không cần thiết với compute node khi vận hành nhưng cần có để cài đặt các gói và cập nhật hệ thống).</li>
    </ul>
    Service layout như sau:
    <br><br>
    <img src="http://docs.openstack.org/mitaka/networking-guide/_images/scenario-classic-ovs-services.png">
    <br><br>
</div>

<h2><a name="arch">2. Kiến trúc</a></h2>
<div>
    <br><br>
    <img src="http://docs.openstack.org/mitaka/networking-guide/_images/scenario-classic-general.png">
    <br><br>

    <h3>Network node</h3>
    <div>
        Network node chứa các thành phần network như sau:
        <ul>
            <li>OpenvSwitch agent quản lý các switch ảo và kết nối giữa chúng, thông qua các port ảo tương tác với các thành phần khác như namespaces, linux bridge và các interfaces vật lý.</li>
            <li>DHCP agent quản lý namespaces <b>qdhcp</b> - là namespaces cung cấp dịch vụ DHCP cho các instances sử dụng project networks.</li>
            <li>L3 agent quản lý <b>qrouter</b> namespaces - thực hiện định tuyết giữa project network và external network và giữa các project network với nhau. Chúng cũng chuyển lưu lượng metadata giữa các máy ảo và metadata agent.</li>
            <li>Metadata agent quản lý metadata của các instances.</li>
        </ul>
        <br><br>
        <img src="http://docs.openstack.org/mitaka/networking-guide/_images/scenario-classic-ovs-network1.png">

        <br><br>

        <img src="http://docs.openstack.org/mitaka/networking-guide/_images/scenario-classic-ovs-network2.png">
        <br><br>        
    </div>
    <h3>Compute node</h3>
    <div>
        Compute node chứa các thành phần sau:
        <ul>
            <li>OpenvSwitch agent</li>
            <li>Linux bridges thực hiện security groups.</li>
        </ul>
        <br><br>
        <img src="http://docs.openstack.org/mitaka/networking-guide/_images/scenario-classic-ovs-compute1.png">
        <br><br>
        <img src="http://docs.openstack.org/mitaka/networking-guide/_images/scenario-classic-ovs-compute2.png">
        <br><br>
    </div>
</div>

<h2><a name="flow">3. Packet flow</a></h2>
<div>
<i><b>Note: </b><b>North-south</b> network traffic chuyển lưu lượng giữa các máy ảo với mạng ngoài. <b>East-west</b> network traffic chuyển lưu lượng giữa các máy ảo.</i>
<h3>Case 1: North-south với các instances với 1 địa chỉ fixed IP</h3>
<div>
    <ul>
        <li>External network:  
            <ul>
                <li>Dải: 172.16.69.0/24</li>
                <li>Pool: 172.16.69.143 - 172.16.69.149</li>
                <li>Project network router interface (TR): 172.16.69.143</li>
            </ul>
        </li>
        <li>Project network:
            <ul>
                <li>Dải: 192.168.224.0/24</li>
                <li>Gateway: 192.168.224.1 - MAC address: TG</li>
            </ul>
        </li>
        <li>Compute node 1: Máy ảo với IP 192.168.224.3 và MAC l1</li>
        <li>Instance nằm trên compute node 1 và sử dụng project network, gửi packet ra mạng ngoài (internet).</li>
    </ul>
    Packet flow trên các node sẽ như sau:
    <br><br>
    <img src="http://docs.openstack.org/mitaka/networking-guide/_images/scenario-classic-ovs-flowns1.png">
    <br><br>
    <h4>Compute node</h4>
    <div>
        <ol>
            <li>Tap interface (1) của máy ảo đưa gói tin tới Linux bridge <b>qbr</b>. Packet chứa địa chỉ MAC đích TG (vì ping ra mạng ngoài)</li>
            <li>Security group rules (2) trên Linux bridge <b>qbr</b> thực hiện theo dõi packet.</li>
            <li>Linux bridge <b>qbr</b> đưa packet tới OpenvSwitch bridge tích hợp <b>br-int</b>.</li>
            <li>Bridge <b>br-int</b> bổ sung internal tag cho project network.</li>
            <li>Với VLAN project network: 
                <ul>
                    <li>Bridge <b>br-int</b> chuyển gói tin tới OpenvSwicth VLAN bridge <b>br-vlan</b></li>
                    <li>Bridge <b>br-vlan</b> thay thế internal tag với VLAN tag của project network.</li>
                    <li>Bridge <b>br-vlan</b> chuyển gói tin tới network node thông qua VLAN interface.</li>
                </ul>
            </li>
            <li>Với VXLAN hoặc GRE project networks: 
                <ul>
                    <li>Bridge <b>br-int</b> chuyển gói tin tới OpenvSwitch tunnel bridge <b>br-tun</b>.</li>
                    <li>OpenvSwitch tunnel bridge <b>br-tun</b> "bọc" packet trong một đường hầm và bổ sung tag để định danh cho project network.</li>
                    <li>OpenvSwitch tunnel bridge <b>br-tun</b> chuyển gói tin tới network node thông qua tunnel interface.</li>
                </ul>
            </li>
        </ol>
    </div>

    <h4>Network node</h4>
    <div>
        <ol>
            <li>Với VLAN project network:
                <ul>
                    <li>VLAN interface đưa gói tin với OpenvSwitch VLAN bridge <b>br-vlan</b></li>
                    <li>OpenvSwitch VLAN bridge <b>br-vlan</b> đưa gói tin tới OpenvSwitch bridge <b>br-int</b></li>
                    <li>Bridge <b>br-int</b> thay thế VLAN tag của project network sang internal tag.</li>
                </ul>
            </li>
            <li>Với VXLAN hoặc GRE project network:
                <ul>
                    <li>Tunnel interface chuyển gói tin tới OpenvSwitch tunnel bridge <b>br-tun</b></li>
                    <li>OpenvSwitch tunnel bridge <b>br-tun</b> bỏ tag (unwrap) packet và bổ sung internal tag cho project network.</li>
                    <li>OpenvSwitch tunnel bridge <b>br-tun</b> chuyển gói tin tới OpenvSwitch bridge <b>br-int</b>.</li>
                </ul>
            </li>
            <li>Bridge <b>br-int</b> chuyển gói tin tới <b>qr</b> interface (3) trong router namespace <b>qrouter</b>. <b>qr</b> interface chứa địa chỉ IP <i>TG</i> của project network gateway.</li>
            <li>Dịch vụ <i>iptables</i> (4) thực hiện SNAT trên packet sử dụng <b>qg</b> interface (5) làm địa chỉ IP nguồn. <b>qg</b> interfaces chứa địa chỉ IP <i>TR</i> của project network gateway.</li>
            <li>Router namespace <b>qrouter</b> chuyển gói tin tới bridge <b>br-int</b> thông qua <b>qg</b> interface.</li>
            <li>Bridge <b>br-int</b> chuyển gói tin tới external bridge <b>br-ex</b></li>
            <li>Bridge <b>br-ex</b> chuyển gói tin ra mạng ngoài thông qua external interface.</li>
        </ol>
    </div>
</div>

<h3>Case 2: North-south với các instance sử dụng floating IP.</h3>
<div>
    <ul>
        <li><b>External network</b>
            <ul>
                <li>Network: 172.16.69.0/24</li>
                <li>Pool: 172.16.69.143 - 172.16.69.149</li>
                <li>Project network router interface: 172.16.69.143 - TR</li>
            </ul>
        </li>
        <li><b>Project network</b>
            <ul>
                <li>Network: 192.168.224.0/24</li>
                <li>Gateway: 192.168.224.1 với MAC address TG</li>
            </ul>
        </li>
        <li><b>Compute node 1: instance với IP 192.168.224.3, MAC l1 và floating IP 172.16.69.144 - F1</b>.</li>
        <li>Instance 1 nằm trên compute node 1 và sử dụng một project network.</li>
        <li>Instance nhận packet từ bên mạng ngoài.</li>
    </ul>
    
    Packet flow sẽ như sau:
    <br><br>
        <img src="http://docs.openstack.org/mitaka/networking-guide/_images/scenario-classic-ovs-flowns2.png">
    <br><br>

    <h4>Network node</h4>
    <div>
        <ol>
            <li>External interface chuyển packet từ mạng ngoài tới external bridge <b>br-ex</b>.</li>
            <li>Bridge <b>br-ex</b> chuyển gói tin tới Openvswitch integration bridge <b>br-int</b>.</li>
            <li>Bridge <b>br-int</b> chuyển gói tin tới <b>qg</b> interface (1) trong router namespace <b>qrouter</b>. <b>qg</b> interface chưa địa chỉ floating IP F1 của instance 1.</li>
            <li> Dịch vụ <i>iptables</i> (2) thực hiện DNAT trên packet sử dụng <b>qr</b> interface (3) làm địa chỉ IP nguồn. <b>qr</b>interface chứa địa chỉ IP của router đối với project network - TG.</li>
            <li>Router namespace <b>qrouter</b> chuyển gói tin tới bridge <b>br-int</b></li>
            <li>Bridge <b>br-int</b> bổ sung internal tag cho project network.</li>
            <li>Đối với VLAN project network:
                <ul>
                    <li>Bridge <b>br-int</b> chuyển gói tin với VLAN bridge <b>br-vlan</b>.</li>
                    <li>Bridge <b>br-vlan</b> thay thế internal tag bằng VLAN tag định danh cho project network.</li>
                    <li>Bridge <b>br-vlan</b> chuyển gói tin tới compute node thông qua VLAN interface.</li>
                </ul>
            </li>
            <li>Đối với VXLAN hoặc GRE project network:
                <ul>
                    <li>Bridge <b>br-int</b> chuyển gói tin tới tunnel bridge <b>br-tun</b>.</li>
                    <li>Bridge <b>br-tun</b> bọc packet trong một VXLAN hoặc GRE tunnel và bổ sung tag định danh cho project network.</li>
                    <li>Bridge <b>br-tun</b> chuyển gói tin tới compute node thông qua tunnel interface.</li>
                </ul>
            </li>
        </ol>
    </div>

    <h4>Compute node</h4>
    <div>
        <ol>
            <li>Với VLAN project network: 
                <ul>
                    <li>VLAN interface chuyển gói tin tới VLAN bridge <b>br-vlan</b>.</li>
                    <li>Bridge <b>br-vlan</b> chuyển gói tin tới bridge <b>br-int</b></li>
                    <li>Bridge <b>br-int</b> bỏ VLAN tag, thay bằng internal tag.</li>
                </ul>
            </li>
            <li>Với VXLAN hoặc GRE project network: 
                <ul>
                    <li>Tunnel interface chuyển gói tin tới bridge <b>br-tun</b></li>
                    <li>Bridge <b>br-tun</b> unwrap packet khỏi đường hầm và bổ sung internal tag cho project network.</li>
                    <li>Bridge <b>br-tun</b> chuyển gói tin tới bridge <b>br-int</b>.</li>
                </ul>
            </li>
            <li>Bridge <b>br-int</b> chuyển gói tin tới Linux bridge <b>qbr</b></li>
            <li>Secutiry group rules (4) trên linux bridge <b>qbr</b> thực hiện các chức năng tường lửa và theo dõi trạng thái của gói tin.</li>
            <li>Linux bridge <b>qbr</b> chuyển gói tin với <b>tap</b> interface (5) của instance 1.</li>
        </ol>
    </div>
</div>

<h3>Case 3: East-west đối với các instances trên các mạng khác</h3>
<div>
    Trường hợp này áp dụng khi truyền thông giữa các máy ảo giữa các project network sử dụng chung một router.
    <ul>
        <li>Project network 1:
            <ul>
                <li>Network: 192.168.1.0/24</li>
                <li>Gateway: 192.168.1.1 với MAC - TG1</li>
            </ul>
        </li>
        <li>
            Project network 2:
            <ul>
                <li>Network: 192.168.2.0/24</li>
                <li>Gateway: 192.168.2.1 với MAC - TG2</li>
            </ul>
        </li>
        <li>
            Compute node 1 chứa instance 1: 192.168.1.11 với MAC - l1
        </li>
        <li>
            Compute node 2 chứa instance 2: 192.168.2.11 với MAC - l2
        </li>
        <li>Cả hai project networks đều chung một router.</li>
        <li>Instance 1 gửi packet tới instance 2</li>
    </ul>

    Packet flow như sau:
    <br><br>
    <img src="http://docs.openstack.org/mitaka/networking-guide/_images/scenario-classic-ovs-flowew1.png">
    <br><br>

    <h4>Compute node 1</h4>
    <ol>
        <li><b>tap</b> interface (1) của instance 1 đưa gói tin tới Linux bridge <b>qbr</b>. Packet chứa địa chỉ MAC đích TG1 vì gửi gói tin ra mạng khác.</li>
        <li>Security group rules (2) trên Linux bridge <b>qbr</b> theo dõi trạng thái của packet.</li>
        <li>Bridge <b>qbr</b> đưa packet tới bridge <b>br-int</b></li>
        <li>Bridge <b>br-int</b> bổ sung internal tag cho project network 1.</li>
        <li>Với VLAN project networks:
            <ul>
                <li>Bridge <b>br-int</b> đưa gói tin tới OpenvSwitch <b>br-vlan</b></li>
                <li>Brige <b>br-vlan</b> thay thế internal tag với VLAN tag định danh cho project network 1.</li>
                <li>Bridge <b>br-vlan</b> đưa gói tin tới network node thông qua VLAN interface.</li>
            </ul>
        </li>
        <li>Với VXLAN hoặc GRE project networks:
            <ul>
                <li>Bridge <b>br-int</b> đưa gói tin tới tunnel bridge <b>br-tun</b></li>
                <li>Bridge <b>br-tun</b> bọc packet trong VXLAN hoặc GRE tunnel và bổ sung tag định danh cho project network 1.</li>
                <li>Bridge <b>br-tun</b> đưa gói tin tới network node thông qua tunnel interface.</li>
            </ul>
        </li>
    </ol>

    <h4>Network node</h4>
    <ol>
        <li>Với VLAN networks:
            <ul>
                <li>VLAN interface đưa gói tin tới OpenvSwitch VLAN bridge <b>br-vlan</b></li>
                <li>Bridge <b>br-vlan</b> đưa gói tin tới bridge <b>br-int</b></li>
                <li>Bridge <b>br-int</b> thay VLAN tag của project network 1 bằng internal tag.</li>
            </ul>
        </li>
        <li>Với VXLAN hoặc GRE project networks:
            <ul>
                <li>Tunnel interface chuyển gói tin tới OpenvSwitch tunnel bridge <b>br-tun</b></li>
                <li>Bridge <b>br-tun</b> unwrap packet và bổ sung internal tag cho project network 1.</li>
                <li>Bridge <b>br-tun</b> đưa packet tới bridge <b>br-int</b></li>
            </ul>
        </li>
        <li>Bridge <b>br-int</b> đưa gói tin tới <b>qr-1</b> interface (3) trong router namespace <b>qrouter</b>. Interface <b>qr-1</b> chứa địa chỉ gateway IP của project network 1 - TG1.</li>
        <li>Router namespace <b>qrouter</b> định tuyến packet tới <b>qr-2</b> interface (4). <b>qr-2</b> interface chưa địa chỉ gateway IP của project network 2 - TG2.</li>
        <li>Router namespace <b>qrouter</b> đưa gói tin tới bridge <b>br-int</b></li>
        <li>Bridge <b>br-int</b> bổ sung internal tag cho project network 2.</li>    
        <li>Với VLAN project network:
            <ul>
                <li>Bridge <b>br-int</b> đưa gói tin tới OpenvSwitch VLAN bridge <b>br-vlan</b></li>
                <li>Bridge <b>br-vlan</b> thay internal tag với VLAN tag của project network 2.</li>
                <li>Bridge <b>br-vlan</b> gửi gói tin tới compute node 2 thông qua VLAN interface.</li>
            </ul>
        </li>
        <li>Với VXLAN hoặc GRE project networks:
            <ul>
                <li>Bridge <b>br-int</b> đưa gói tin tới tunnel bridge <b>br-tun</b></li>
                <li>Bridge <b>br-tun</b> bọc packet trong VXLAN hoặc GRE tunnel và bổ sung tag để định danh project network 2.</li>
                <li>Bridge <b>br-tun</b> gửi gói tin tới compute node 2 thông qua tunnel interface.</li>
            </ul>
        </li>      
    </ol>

    <h4>Compute node 2</h4>
    <ol>
        <li>Với VLAN project networks:
            <ul>
                <li>VLAN interface đưa gói tin tới bridge <b>br-vlan</b></li>
                <li>Bridge <b>br-vlan</b> gửi gói tin tới bridge <b>br-int</b></li>
                <li>Bridge <b>br-int</b> thay VLAN tag của project network 2 với internal tag.</li>
            </ul>
        </li>
        <li>Với VXLAN hoặc GRE project networks:
            <ul>
                <li>Tunnel interface gửi gói tin tới tunnel bridge <b>br-tun</b></li>
                <li>Bridge <b>br-tun</b> unwrap packet và bổ sung internal tag cho project network 2.</li>
                <li>Bridge <b>br-tun</b> đưa gói tin tới bridge <b>br-int</b></li>
            </ul>
        </li>
        <li>Bridge <b>br-int</b> đưa gói tin với Linux bridge <b>qbr</b></li>
        <li>Security group rules (5) trên Linux bridge <b>qbr</b> thực hiện dịch vụ firewall và theo dõi trạng thái gói tin.</li>
        <li>Bridge <b>qbr</b> đưa gói tin tới <b>tap</b> interface (6) trên instance 2.</li>        
    </ol>
</div>

<h3>Case 4: East-west traffic đối với các instance trên cùng project network</h3>
<div>
    <ul>
        <li>Project network: 192.168.224.0/24</li>
        <li>Compute node 1 với instance 1 với IP 192.168.224.3, MAC l1</li>
        <li>Compute node 2 với instance 2 với IP 192.168.224.4, MAC l2</li>
        <li>Cả 2 instance sử dụng chung project network.</li>
        <li>Instance 1 gửi packets cho instance 2.</li>
        <li>OpenvSwitch agent chịu trách nhiệm switching nội bộ project network.</li>
    </ul>
    Packet flow như sau:
    <br><br>
        <img src="http://docs.openstack.org/mitaka/networking-guide/_images/scenario-classic-ovs-flowew2.png">
    <br><br>

    <h4>Compute node 1</h4>
    <ol>
        <li><b>tap</b> interface (1) của instance 1 đưa gói tin tới linux bridge <b>qbr</b>. Packet chứa địa chỉ MAC đích l2 bởi vì hai instance cùng một project network.</li>
        <li>Security group rules (2) trên linux bridge <b>qbr</b> thực hiện theo dõi packet.</li>
        <li>Bridge <b>qbr</b> đưa gói tin tới bridge <b>br-int</b>.</li>
        <li>Bridge <b>br-int</b> bổ sung internal tag cho project network.</li>
        <li>Với VLAN project networks:
            <ul>
                <li>Bridge <b>br-int</b> đưa gói tin tới bridge <b>br-vlan</b></li>
                <li>Bridge <b>br-vlan</b> thay thế internal tag với VLAN tag định danh cho project network 1.</li>
                <li>Bridge <b>br-vlan</b> gửi gói tin sang compute node 2 thông qua VLAN interface.</li>
            </ul>
        </li>
        <li>Với VXLAN hoặc GRE project networks:
            <ul>
                <li>Bridge <b>br-int</b> gửi gói tin tới tunnel bridge <b>br-tun</b></li>
                <li>Bridge <b>br-tun</b> bọc packet trong đường hầm VXLAN hoặc GRE, bổ sung thêm tag định danh cho project network.</li>
                <li>Bridge <b>br-tun</b> gửi gói tin sang compute node 2 qua tunnel interface.</li>
            </ul>
        </li>
    </ol>

    <h4>Compute node 2</h4>
    <ol>
        <li>Với VLAN project networks:
            <ul>
                <li>VLAN interface gửi gói tin tới vlan bridge <b>br-vlan</b></li>
                <li>Bridge <b>br-vlan</b> gửi gói tin sang bridge <b>br-int</b></li>
                <li>Bridge <b>br-int</b> thay thế VLAN tag bằng internal tag cho project network.</li>
            </ul>
        </li>
        <li>Với VXLAN hoặc GRE project networks:
            <ul>
                <li>Tunnel interface gửi gói tin tới tunnel bridge <b>br-tun</b></li>
                <li>Bridge <b>br-tun</b> unwrap packet và bổ sung internal tag cho project network.</li>
                <li>Bridge <b>br-tun</b> gửi packet tới bridge <b>br-int</b></li>
            </ul>
        </li>
        <li>Bridge <b>br-int</b> gửi packet tới bridge <b>qbr</b></li>
        <li>Security group rules (3) bridge <b>qbr</b> thực hiện các chức năng firewalling và theo dõi trạng thái packet.</li>
        <li>Bridge <b>qbr</b> đưa packet tới <b>tap</b> interface (4) của instance 2.</li>        
    </ol>
</div>

</div>

<h2><a name="cfg">4. Cấu hình</a></h2>
<div>
    Dưới đây là cấu hình mẫu với OpenvSwitch sử dụng VXLAN tunnel project network.

    <h3>Controller node</h3>
    <div>
        <ol>
            <li>Trong file <code>/etc/neutron/neutron.conf</code>, chỉnh sửa trong section <code>[DEFAULT]</code> như sau:
<pre>
    <code>
[DEFAULT]
core_plugin = ml2
service_plugins = router
allow_overlapping_ips = True
    </code>
</pre>
            </li>
            <li>Trong file <code>/etc/neutron/plugins/ml2/ml2_conf.ini</code>, cấu hình như sau:
                <ul>
                    <li>Cấu hình drivers và network types:
<pre>
    <code>
[ml2]
type_drivers = flat,vlan,gre,vxlan
tenant_network_types = vxlan
mechanism_drivers = openvswitch,l2population
extension_drivers = port_security
    </code>
</pre>
                    </li>
                    <li>Cấu hình network mappings và ID ranges, chú ý ở đây chỉ cấu hình IP ranges cho VXLAN tunnel trong section <code>[ml2_type_vxlan]</code>, nếu sử dụng VLAN hoặc GRE tunnel project network, điều chỉnh lại cho phù hợp trong các section <code>[ml2_type_vlan]</code> và <code>[ml2_type_gre]</code>.
<pre>
    <code>
[ml2_type_flat]
flat_networks = provider

[ml2_type_vlan]
#network_vlan_ranges = provider,vlan:500:600

[ml2_type_gre]
#tunnel_id_ranges = 1:1000

[ml2_type_vxlan]
vni_ranges = 1:1000
    </code>
</pre>
                    </li>
                    <li>Cấu hình security group driver:
<pre>
    <code>
[securitygroup]
firewall_driver = iptables_hybrid
    </code>
</pre>
                    </li>
                </ul>
            </li>
            <li>Khởi động lại neutron server: <code>service neutron-server restart</code></li>
        </ol>
    </div>

    <h3>Network node</h3>
    <div>
    <i><b>Chú ý:</b> ở bài viết này cài đặt chung các dịch vụ của controller node và network node nên cấu hình các file trên network node tương đương với việc cấu hình trên controller node.</i>
    <ol>
        <li>Trong file <code>/etc/neutron/plugins/ml2/openvswitch_agent.ini</code>, chỉnh sửa như sau:
<pre>
    <code>
[ovs]
local_ip = TUNNEL_INTERFACE_IP_ADDRESS
bridge_mappings = provider:br-ex
#bridge_mappings = vlan:br-vlan,provider:br-ex

[agent]
tunnel_types = vxlan
l2_population = True

[securitygroup]
firewall_driver = iptables_hybrid
    </code>
</pre>  
            Chú ý thiết lập địa chỉ <code>TUNNEL_INTERFACE_IP_ADDRESS</code> phù hợp với cấu hình, ở bài viết này sử dụng dải <code>10.10.20.0/24</code> làm tunnel network với giá trị <code>TUNNEL_INTERFACE_IP_ADDRESS=10.10.20.193</code>.
        </li>
        <li>Chỉnh sửa trong file <code>/etc/neutron/l3_agent.ini</code> như sau:
<pre>
    <code>
[DEFAULT]
interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
external_network_bridge =
    </code>
</pre>
        </li>
        <li>Chỉnh sửa trong file <code>/etc/neutron/dhcp_agent.ini</code> như sau:
<pre>
    <code>
[DEFAULT]
interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
enable_isolated_metadata = True      
    </code>
</pre>
        </li>
        <li>Chỉnh sửa trong file <code>/etc/neutron/metadata_agent.ini</code> như sau:
<pre>
    <code>
[DEFAULT]
nova_metadata_ip = controller
metadata_proxy_shared_secret = METADATA_SECRET
    </code>
</pre>
        Chú ý đặt giá trị <code>METADATA_SECRET</code> phù hợp, ở đây thiết lập giá trị này giống với mật khẩu cho các dịch vụ để đồng bộ với <code>METADATA_SECRET=Welcome123</code>.
        </li>

        <li>Chú ý, nếu trước đó cấu hình với mechanism drivers và type drivers khác thì cần phải xóa toàn bộ instance và các network, router của cấu hình cũ đi, gỡ các gói mechanism drivers và type drivers cần thiết. Ngoài ra cũng cần flush database neutron, để áp dụng cấu hình network mới vào cơ sở dữ liệu. Thực hiện như sau:
            <ul>
                <li>Vào trình quản lý database: <code>mysql -u root -p</code></li>
                <li>Trong giao diện quản lý database, xóa database <code>neutron</code> cũ và tạo database <code>neutron</code> mới, thiết lập permission:
<pre>
    <code>
DROP DATABASE neutron;
CREATE DATABASE neutron;  
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' \
  IDENTIFIED BY 'NEUTRON_DBPASS';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' \
  IDENTIFIED BY 'NEUTRON_DBPASS';  
EXIT;
    </code>
</pre>
                Thiết lập giá trị <code>NEUTRON_DBPASS</code> cho phù hợp.
                </li>
                <li>Tiến hành cập nhật lại các cấu hình đã thiết lập vào <code>neutron</code> database:
<pre>
    <code>
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
    </code>
</pre>
                </li>
            </ul>

        </li>

        <li>Khởi động lại các dịch vụ cần thiết: 
<pre>
    <code>
service openvswitch-switch restart
service neutron-openvswitch-agent restart
service neutron-l3-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart
    </code>
</pre>
        </li>
    </ol>
        
    </div>

    <h3>Compute nodes</h3>
    <div>
        <ol>
            <li>Chỉnh sửa file <code>/etc/neutron/plugins/ml2/openvswitch_agent.ini</code> như sau:
<pre>
    <code>
[ovs]
local_ip = TUNNEL_INTERFACE_IP_ADDRESS
bridge_mappings =
#bridge_mappings = vlan:br-vlan

[agent]
tunnel_types = vxlan
l2_population = True

[securitygroup]
firewall_driver = iptables_hybrid      
    </code>
</pre>
            Chú ý thiết lập giá trị <code>TUNNEL_INTERFACE_IP_ADDRESS</code> phù hợp, ví dụ ở đây thiết lập <code>TUNNEL_INTERFACE_IP_ADDRESS=10.10.20.194</code>
            </li>
            <li>Khởi động lại các dịch vụ cần thiết:
<pre>
    <code>
service openvswitch-switch restart
service neutron-openvswitch-agent restart
    </code>
</pre>
            </li>
        </ol>
    </div>
</div>

<h2><a name="verify">5. Xác nhận cấu hình và tạo network</a></h2>
<ol>
    <li>Xác nhận các dịch vụ hoạt động ổn định (thực hiện trên controller node):
<pre>
    <code>
source admin-openrc
neutron agent-list
    </code>
</pre>
    Kết quả trả về thành công sẽ tương tự như sau:
<pre>
    <code>
+--------------------------------------+--------------------+------------+-------------------+-------+----------------+---------------------------+
| id                                   | agent_type         | host       | availability_zone | alive | admin_state_up | binary                    |
+--------------------------------------+--------------------+------------+-------------------+-------+----------------+---------------------------+
| 1c50ade6-b9f8-42f4-85d4-a781818e665c | DHCP agent         | controller | nova              | :-)   | True           | neutron-dhcp-agent        |
| 234bf979-b6b9-40e4-90bc-13b2e11706b6 | Open vSwitch agent | compute1   |                   | :-)   | True           | neutron-openvswitch-agent |
| 444ea014-1fa5-488a-aa10-bc01b398f99b | Metadata agent     | controller |                   | :-)   | True           | neutron-metadata-agent    |
| 6307bb8a-9f60-479e-9b1e-1a328eb588ab | Open vSwitch agent | controller |                   | :-)   | True           | neutron-openvswitch-agent |
| 8bd87ff7-71e0-4457-a632-c03b704bc291 | L3 agent           | controller | nova              | :-)   | True           | neutron-l3-agent          |
+--------------------------------------+--------------------+------------+-------------------+-------+----------------+---------------------------+
    </code>
</pre>
    </li>
    <li> Tạo các network
        <ul>
            <li>Tạo external network:
<pre>
    <code>
neutron net-create ext-net --router:external True \
  --provider:physical_network provider --provider:network_type flat
Created a new network:
+---------------------------+--------------------------------------+
| Field                     | Value                                |
+---------------------------+--------------------------------------+
| admin_state_up            | True                                 |
| availability_zone_hints   |                                      |
| availability_zones        |                                      |
| created_at                | 2016-09-26T04:02:10                  |
| description               |                                      |
| id                        | 4aa5e29c-25d0-4b06-b611-93f7c5aa5acd |
| ipv4_address_scope        |                                      |
| ipv6_address_scope        |                                      |
| is_default                | False                                |
| mtu                       | 1500                                 |
| name                      | ext-net                              |
| port_security_enabled     | True                                 |
| provider:network_type     | flat                                 |
| provider:physical_network | provider                             |
| provider:segmentation_id  |                                      |
| router:external           | True                                 |
| shared                    | False                                |
| status                    | ACTIVE                               |
| subnets                   |                                      |
| tags                      |                                      |
| tenant_id                 | f18938908e3a49a1a1a23385e0162421     |
| updated_at                | 2016-09-26T04:02:10                  |
+---------------------------+--------------------------------------+
    </code>
</pre>
            </li>
            <li>Tạo subnet cho external network:
<pre>
    <code>
neutron subnet-create ext-net --name ext-subnet --allocation-pool \
  start=172.16.69.143,end=172.16.69.149 --disable-dhcp \
  --gateway 172.16.69.1 172.16.69.0/24
Created a new subnet:
+-------------------+----------------------------------------------------+
| Field             | Value                                              |
+-------------------+----------------------------------------------------+
| allocation_pools  | {"start": "172.16.69.143", "end": "172.16.69.149"} |
| cidr              | 172.16.69.0/24                                     |
| created_at        | 2016-09-26T04:04:47                                |
| description       |                                                    |
| dns_nameservers   |                                                    |
| enable_dhcp       | False                                              |
| gateway_ip        | 172.16.69.1                                        |
| host_routes       |                                                    |
| id                | b13fb9fa-5c2b-42be-bed2-8f8f42dd21ea               |
| ip_version        | 4                                                  |
| ipv6_address_mode |                                                    |
| ipv6_ra_mode      |                                                    |
| name              | ext-subnet                                         |
| network_id        | 4aa5e29c-25d0-4b06-b611-93f7c5aa5acd               |
| subnetpool_id     |                                                    |
| tenant_id         | f18938908e3a49a1a1a23385e0162421                   |
| updated_at        | 2016-09-26T04:04:47                                |
+-------------------+----------------------------------------------------+
    </code>
</pre>
            </li>
            <li>Kiểm tra lại thông tin của project <code>demo</code> và lấy id của project <code>demo</code>
<pre>
    <code>
openstack project show demo
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | Demo Project                     |
| domain_id   | 35a346d115254feab3e95559e5b85f82 |
| enabled     | True                             |
| id          | eb40c85edade4f869fd30122f302b31f |
| is_domain   | False                            |
| name        | demo                             |
| parent_id   | 35a346d115254feab3e95559e5b85f82 |
+-------------+----------------------------------+
    </code>
</pre>
            </li>
            <li>Tạo project network trên project <code>demo</code>, sử dụng giá trị <code>id</code> ở lệnh kiểm tra phía trên:
<pre>
    <code>
neutron net-create demo-net --tenant-id eb40c85edade4f869fd30122f302b31f \
  --provider:network_type vxlan
Created a new network:
+---------------------------+--------------------------------------+
| Field                     | Value                                |
+---------------------------+--------------------------------------+
| admin_state_up            | True                                 |
| availability_zone_hints   |                                      |
| availability_zones        |                                      |
| created_at                | 2016-09-26T04:15:28                  |
| description               |                                      |
| id                        | cd1decfc-60d7-4c56-9cc7-56152d74abcd |
| ipv4_address_scope        |                                      |
| ipv6_address_scope        |                                      |
| mtu                       | 1450                                 |
| name                      | demo-net                             |
| port_security_enabled     | True                                 |
| provider:network_type     | vxlan                                |
| provider:physical_network |                                      |
| provider:segmentation_id  | 10                                   |
| router:external           | False                                |
| shared                    | False                                |
| status                    | ACTIVE                               |
| subnets                   |                                      |
| tags                      |                                      |
| tenant_id                 | 35a346d115254feab3e95559e5b85f82     |
| updated_at                | 2016-09-26T04:15:28                  |
+---------------------------+--------------------------------------+
    </code>
</pre>
            </li>
            <li>Thiết lập biến môi trường để thực hiện các lệnh sau trên project <code>demo</code>: <code>source demo-openrc</code></li>
            <li>Tạo subnet cho project network <code>demo-net</code>
<pre>
    <code>
neutron subnet-create demo-net --name demo-subnet --gateway 192.168.224.1 \
  192.168.224.0/24
Created a new subnet:
+-------------------+------------------------------------------------------+
| Field             | Value                                                |
+-------------------+------------------------------------------------------+
| allocation_pools  | {"start": "192.168.224.2", "end": "192.168.224.254"} |
| cidr              | 192.168.224.0/24                                     |
| created_at        | 2016-09-26T04:26:28                                  |
| description       |                                                      |
| dns_nameservers   |                                                      |
| enable_dhcp       | True                                                 |
| gateway_ip        | 192.168.224.1                                        |
| host_routes       |                                                      |
| id                | b7082d51-b5a9-493a-af7e-aec5d702e6a8                 |
| ip_version        | 4                                                    |
| ipv6_address_mode |                                                      |
| ipv6_ra_mode      |                                                      |
| name              | demo-subnet                                          |
| network_id        | 345974f8-569f-4b09-9b87-4d294520dc28                 |
| subnetpool_id     |                                                      |
| tenant_id         | eb40c85edade4f869fd30122f302b31f                     |
| updated_at        | 2016-09-26T04:26:28                                  |
+-------------------+------------------------------------------------------+
    </code>
</pre>
            </li>
            <li>Tạo project router:
<pre>
    <code>
neutron router-create demo-router
Created a new router:
+-------------------------+--------------------------------------+
| Field                   | Value                                |
+-------------------------+--------------------------------------+
| admin_state_up          | True                                 |
| availability_zone_hints |                                      |
| availability_zones      |                                      |
| description             |                                      |
| external_gateway_info   |                                      |
| id                      | f17519bc-7d0c-4e1c-b4d2-96729153786e |
| name                    | demo-router                          |
| routes                  |                                      |
| status                  | ACTIVE                               |
| tenant_id               | eb40c85edade4f869fd30122f302b31f     |
+-------------------------+--------------------------------------+
    </code>
</pre>
            </li>
            <li>Thiết lập project subnet làm một interface trên router:
<pre>
    <code>
neutron router-interface-add demo-router demo-subnet   
    </code>
</pre>
            </li>
            <li>Thiết lập gateway tới external network trên router:
<pre>
    <code>
neutron router-gateway-set demo-router ext-net
    </code>
</pre>
            </li>
        </ul>
    </li>
</ol>

<h2><a name="ref">6. Tham khảo</a></h2>
<div>
    [1] - <a href="http://docs.openstack.org/mitaka/networking-guide/scenario-classic-ovs.html">http://docs.openstack.org/mitaka/networking-guide/scenario-classic-ovs.html</a>
</div>