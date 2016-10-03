# Modular Layer 2 (ML2) plug-in
# Mục lục
<h3><a href="#arch">1. Kiến trúc ML2 plug-in</a></h3>
<h3><a href="#cfg">2. Cấu hình ML2 plug-in</a></h3>
<ul>
    <li><a href="#21">2.1. Network type drivers</a></li>
    <li><a href="#22">2.2. Mechanism drivers</a></li>
    <li><a href="#23">2.3. Agents</a></li>
    <li><a href="#24">2.4. Security</a></li>
</ul>
<h3><a href="#backends">3. Network Back Ends trong OpenStack</a></h3>
<h3><a href="#ref">4. Tham khảo</a></h3>

---

<h2><a name="arch">1. Kiến trúc ML2 plug-in</a></h2>
<div>
    Modular Layer 2 (ML2) plugin neutron plug-in là framework cho phép OpenStack Networking sử dụng đồng thời nhiều công nghệ networking lớp 2 trong hệ thống data center phức tạp thực tế. ML2 framework phân biệt hai loại driver có thể cấu hình:
    <ul>
        <li><b>Type drivers: </b>
        Định nghĩa việc OpenStack network triển khai về mặt kỹ thuật như thế nào. Ví dụ: VXLAN.
        Mỗi kiểu network được quản lý bởi một kiểu driver ML2 khác nhau. Các kiểu drivers duy trì và cần thiết để chỉ định trạng thái của network. Chúng chứng thực thông tin cụ thể cho provider networks và có nhiệm vụ cấp phát free segment trong tenant network.
        </li>
        <li><b>Mechanism drivers: </b>
        Định nghĩa mô hình để truy cập một network trong OpenStack theo một loại driver cụ thể. Ví dụ: Open vSwitch driver.
        <br>Mechanism driver chịu trách nhiệm lấy thông tin được thiết lập bởi <b>type driver</b> và đảm bảo rằng nó đựa áp dụng phù hợp với mechanism. Mechanism driver có thể sử dụng L2 agents (thông qua RPC) và/hoặc tương tác trực tiếp với thiết bị mạng ngoài hoặc các controllers.
        </li>
    </ul>
    Các ML2 driver hỗ trợ - Mechanism drivers tương ứng với L2 agents:
    <table>
        <tr>
            <td><b>type driver/mech driver</b></td>
            <td><b>Flat</b></td>
            <td><b>VLAN</b></td>
            <td><b>VXLAN</b></td>
            <td><b>GRE</b></td>
        </tr>

        <tr>
            <td>Open vSwitch</td>
            <td>yes</td>
            <td>yes</td>
            <td>yes</td>
            <td>yes</td>
        </tr>

        <tr>
            <td>Linux bridge</td>
            <td>yes</td>
            <td>yes</td>
            <td>yes</td>
            <td>yes</td>
        </tr>

        <tr>
            <td>SRIOV</td>
            <td>yes</td>
            <td>yes</td>
            <td>no</td>
            <td>no</td>
        </tr>

        <tr>
            <td>MacVTap</td>
            <td>yes</td>
            <td>yes</td>
            <td>no</td>
            <td>no</td>
        </tr>

        <tr>
            <td>L2 population</td>
            <td>no</td>
            <td>no</td>
            <td>yes</td>
            <td>yes</td>
        </tr>

    </table>
</div>
<h2><a name="cfg">2. Cấu hình ML2 plug-in</a></h2>
<ul>
    <li><h3><a name="21">2.1. Network type drivers</a></h3>
    Để cho phép type drivers trong ML2 plug-in, chỉnh sửa file <code>/etc/neutron/plugins/ml2/ml2_conf.ini</code>
    <pre>
        <code>
[ml2]
type_drivers = flat,vlan,vxlan,gre
        </code>
    </pre>
    Các type driver có sẵn: Flat, VLAN, GRE, VXLAN.
    <h4>Các kiểu Provider network</h4>
    <div>
        Provider networks cung cấp kết nối giống các project network. Tuy nhiên chỉ có người dùng quản trị mới có thể quản lý các networks này bởi provider network tương tác trực tiếp với hạng tầng mạng vật lý.
        <ul>
            <li><b>Flat: </b>Người quản trị phải cấu hình một danh sách tên của các physical có thể sử dụng cho providers networks.</li>
            <li><b>VLAN: </b>Người quản trị phải cấu hình một danh sách tên của các physical có thể sử dụng cho providers networks.</li>
            <li><b>GRE: </b>Không cần cấu hình thêm</li>
            <li><b>VXLAN: </b>Người quản trị có thể cấu hình VXLAN multicast groups sẽ sử dụng. Tuy nhiên cấu hình VXLAN multicast group không phù hợp với Open vSwitch agent.</li>
        </ul>
    </div>

    <h4>Các kiểu Project network</h4>
    <div>
        Project (tenant) networks cung cấp kết nối cho các máy ảo trong một project cụ thể. Ngwpif dùng thông thường có thể quản lý các project networks trong hạn định cấp phát bởi người quản trị định nghĩa cho họ.
        <br>Cấu hình các project network được đặt trong file <code>/etc/neutron/plugins/ml2/ml2_conf.ini</code> trên neutron server.
        <ul>
            <li><b>VLAN: </b>người quản trị cần phải cấu hình miền VLAN IDs có thể sử dụng để cấp phát cho project (tenant) network</li>
            <li><b>GRE: </b>người quản trị cần phải cấu hình miền các tunnel IDs có thể sử dụng để cấp phát cho project (tenant)</li>
            <li><b>VXLAN: </b>người quản trị cần cấu hình miền VXLAN IDs có thể sử dụng để cấp phát cho project (tenant).</li>
        </ul>
    </div>
    </li>
    <li><h3><a name="22">2.2. Mechanism drivers</a></h3>
    Để kích hoạt mechanism drivers trong ML2 plug-in, chỉnh sửa trong file <code>/etc/neutron/plugins/ml2/ml2_conf.ini</code> trong neutron server:
    <pre>
        <code>
[ml2]
mechanism_drivers = ovs,l2pop
        </code>
    </pre>
    <ul>
        <li><b>Linux bridge: </b>Không cần cấu hình thêm đối với mechanism driver nhưng cần cấu hình thêm với agent.</li>
        <li><b>Open vSwitch: </b>Không cần cấu hình thêm đối với mechanism driver nhưng cần cấu hình thêm với agent.</li>
        <li><b>SRIOV: </b>Người quản trị cần định nghĩa danh sách các PCI hardware sẽ được sử dụng bởi OpenStack.</li>
        <li><b>MacVTap: </b>Không cần cấu hình thêm đối với mechanism driver nhưng cần cấu hình thêm với agent.</li>
        <li><b>L2 population</b></li>
        <li><b>Specialized: </b>
        <ul>
            <li>Open source: các mechanism drivers có thể được tích hợp:
            <ul>
                <li>OpenDaylight</li>
                <li>OpenContrail</li>
            </ul>
            <ul>
                
            </ul>
            </li>
            <li>Proprieaty(vendor):  các mechanism drivers của các nhà cung cấp có thể tích hợp với các type drivers.</li>
        </ul>
        </li>
    </ul>
    </li>
    <li><h3><a name="23">2.3. Agents</a></h3>
    <h4>L2 agent</h4>
    <div>
        Một L2 Agent phục vụ kết nối layer 2 (ethernet) tới tài nguyên của OpenStack. Nó chạy trên các Network node và Compute node.
        <ul>
            <li>Open vSwitch agent: cấu hình OpenvSwitch để tạo ra L2 networks cho các tài nguyên trong OpenStack.<li>
            <li>Linux bridge agent: cấu hình Linux bridges để tạo ra L2 network cấp cho các tài nguyên trong OpenStack.</li>
            <li>SRIOV NIC switch agent: cấu hình các PCI VFs để tạo ra L2 network cho các máy ảo trong OpenStack, không hỗ trợ các tài nguyên khác như routers, DHCP,...</li>
            <li>MacVTap agent: sử dụng MacVTap devices (hỗ trợ mở macvtap driver) tạo ra L2 networks cho OpenStack instances, không hỗ trợ các tài nguyên như routers, DHCP,...</li>
        </ul>
    </div>

    <h4>L3 agent</h4>
    <div>
        L3 agent cung cấp các dịch vụ lớp 3 nâng cao như các router ảo và floating IPs. Nó yêu cầu chạy song song với L2 agent.
    </div>

    <h4>DHCP agent</h4>
    <div>
        Đóng vai trò cung cấp các dịch vụ DHCP và RADVD (Router Advertisement Daemon). Nó yêu cầu chạy cùng với L2 agent trên cùng node.
    </div>

    <h4>Metadata agent</h4>
    <div>
        Cho phép các máy ảo truy cập cloud-init metadata và dữ liệu của các use thông qua mạng. Nó yêu cầu chạy cùng với L2 agent trên cùng một node. 
    </div>

    <h4>L3 metering agent</h4>
    <div>
        cho phép đo đạc lưu lượng lớp 3, yêu cầu chạy L3 agent trên cùng 1 node.
    </div>
    </li>
    <li><h3><a name="24">2.4. Security</a></h3>
    L2 agents hỗ trợ một số cấu hình bảo mật quan trọng:
    <ul>
        <li>Security Groups</li>
        <li>Arp Spoofing Prevention</li>
    </ul>
    </li>
</ul>

<h2><a name="backends">3. Network Back Ends trong OpenStack</a></h2>
<div>
    Hai tùy chọn networking back ends:
    <ul>
        <li><b>Nova networking: </b>
        Back end này đã không còn được chấp nhận trên lộ trình phát triển của OpenStack, tuy nhiên vẫn được duy trì.
        </li>
        <li><b>OpenStack Networking (neutron): </b>Back end này được cân nhắc sử dụng làm thành phần chủ đạo của SDN của OpenStack và đang được phát triển.
        </li>
    </ul>
    Các tùy chọn khi sử dụng OpenStack Networking (Neutron):
    <ul>
        <li>
            Sử dụng overlay network: OpenStack Networking hỗ trợ GRE và VXLAN tunneling để cô lập lưu lượng giữa các máy ảo. Sử dụng GRE hoặc VXLAN không yêu cầu cấu hình VLAN trên network fabric (mạng trong đó các nodes kết nối nội bộ với nhau thông qua một hoặc nhiều switches), chỉ yêu cầu network vật lý cung cấp kết nối IP giữa các node. Ngoài ra, VXLAN hoặc GRE về mặt lý thuyết cung cấp được tới 16 triệu network IDs khác nhau, lớn hơn nhiều so với con số 4094 đối với chuẩn 802.1q VLAN ID. 
        </li>
        <li>Nếu yêu cầu sử dụng các địa chỉ IP chồng lấn nhau giữa các tenant: OpenStack Networking sử dụng <b>network namespaces</b> do linux kernel cung cấp, cho phép các tenants khác nhau sử dụng chung dải địa chỉ trên cùng 1 Compute node mà không gặp bất kì vấn đề gì về việc xuyên nhiễu hay chồng lấn về địa chỉ IP. Tính năng này phù hợp trong môi trường triển khai lớn nhiều tenant. </li>
        <li>Nếu yêu cầu các dịch vụ FWaaS hoặc LaaS, OpenStack Networking cung cấp sẵn các dịch vụ này, các tenant có thể quản lý các dịch vụ này trên dashboard mà không cần sự can thiệp của người quản trị.</li>
    </ul>

</div>

<h2><a name="ref">4. Tham khảo</a></h2>
<div>
    [1] - <a href="http://docs.openstack.org/mitaka/networking-guide/config-ml2.html">http://docs.openstack.org/mitaka/networking-guide/config-ml2.html</a>
</div>