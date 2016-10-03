# Căn bản OpenStack Networking
# Mục lục
<h3><a href="#concept">1. Các khái niệm</a></h3>
<h3><a href="#hierachy">2. Hệ thống phân cấp các thành phần và dịch vụ</a></h3>
<ul>
    <li><a href="#server">2.1 Server</a></li>
    <li><a href="#plugin">2.2. Plug-ins</a></li>
    <li><a href="#agent">2.3. Agents</a></li>
    <li><a href="#service">2.4 Services</a></li>
</ul>
<h3><a href="#ref">3. Tham khảo</a></h3>

--- 

<div>
OpenStack Networking cho phép tạo và quản lý networks, subnets, ports để các OpenStack services khác có thể sử dụng. Các plug-in có thể triển khai để sử dụng được các thiết bị và phần mềm networking khác, làm cho OpenStack trở nên linh hoạt cả về kiến trúc và khi triển khai.
<br>
Dịch vụ Networking, hay <b>neutron</b> cung cấp một API cho phép định nghĩa kết nối mạng và đánh địa chỉ trên cloud, cung cấp "kết nối mạng như một dịch vụ" cho các dịch vụ khác trong cloud OpenStack. Neutron cho phép người vận hành tận dụng nhiều công nghệ mạng khác nhau để vận hành hệ thống mạng trên cloud của họ (các công nghệ về network namespaces, Linux bridges, OpenvSwitch, dnsmasq). Neu tron cũng cung cấp một API để cấu hình và quản lý nhiều dịch vụ network khác như L3 forwarding, NAT, load balancing, firewall, VPNs.
<br>
Các component bao gồm:
<h4>API server</h4>
<div>
    OpenStack Networking API hỗ trợ Layer2 networking và IP address management (IPAM - quản lý địa chỉ IP), cũng như một extension để xây dựng router Layer 3 cho phép định tuyến giữa các networks Layer 2 và các gateway để ra mạng bên ngoài. OpenStack Networking cung cấp một danh sách các plug-ins (đang ngày càng tăng lên) cho phép tương tác với nhiều công nghệ mạng mã nguồn mở và cả thương mại, bao gồm các routers, switches, switch ảo và SDN controller.
</div>

<h4>OpenStack Networking plug-in và các agents</h4>
<div>
    Các plugin và các agent này cho phép gắn và gỡ các ports, tạo ra network hay subnet, và đánh địa chỉ IP. Lựa chọn plugin và agents nào là tùy thuộc vào nhà cung cấp và công nghệ sử dụng trong hệ thống cloud nhất định. Điều quan trọng là tại một thời điểm chỉ sử dụng được một plug-in.
</div>

<h4>Messaging queue</h4>
<div>
    Tiếp nhận và định tuyến các RPC requests giữa các agents để hoàn thành quá trình vận hành API. Các Message queue được sử dụng trong ML2 plugin để thực hiện truyền thông RPC giữa neutron server và các neutron agents chạy trên mỗi hypervisor, cụ thể là các ML2 driver cho <b>Open vSwitch</b> và <b>Linux bridge.</b>
</div>

</div>

<h2><a name="concept">1. Các khái niệm</a></h2>
<div>
 <h4>Tenant networks</h4>
 <div>
     Người dùng tạo ra <b>tenant network</b> để kết nối nội bộ trong projects. Mặc định các network này hoàn toàn cô lập và không chia sẻ với các project khác. OpenStack Networking hỗ trợ các kiểu tenant network sau:
     <ul>
         <li><b>Flat: </b>
            Tất cả các instances nằm trong cùng một mạng, và có thể chia sẻ với hosts. Không hề sử dụng VLAN tagging hay hình thức tách biệt về network khác.
         </li>

         <li><b>VLAN: </b> 
            Kiểu này cho phép các users tạo nhiều provicer hoặc tenant network sử dụng VLAN IDs(chuẩn 802.1Q tagged) tương ứng với VLANs trong mạng vật lý. Điều này cho phép các instances giao tiếp với nhau trong môi trường cloud. Chúng có thể giao tiếp với servers, firewalls, load balancers vật lý và các hạ tầng network khác trên cùng một VLAN layer 2.
         </li>

         <li><b>GRE và VXLAN: </b>
            VXLAN và GRE là các giao thức đóng gói tạo nên overlay networks để kích hoạt và kiểm soát việc truyền thông giữa các máy ảo (instances). Một router dược yêu cầu để cho phép lưu lượng đi ra luồng bên ngoài tenant network GRE hoặc VXLAN. Một router cũng có thể yêu cầu để kết nối một tenant network với mạng bên ngoài (ví dụ Internet). Router cung cấp khả năng kết nối tới instances trực tiếp từ mạng bên ngoài sr dụng các địa chỉ floating IP.
         </li>
     </ul>

 </div>

  <h4>Provider networks</h4>
 <div>
     Người quản trị OpenStack tạo ra các provider networks. Các network này map tới mạng vật lý trong datacenter. Kiểu network phù hợp với <b>provider network</b> là flat (untagged) và VLAN (802.1Q tagged).
     <br><br>
     <img src="http://docs.openstack.org/mitaka/networking-guide/_images/NetworkTypes.png">
     <br><br>
 </div>

  <h4>Subnets</h4>
 <div>
     Là một khối tập hợp các địa chỉ IP và đã được cấu hình. Quản lý các địa chỉ IP của subnet do IPAM driver thực hiện. Subnet được dùng để cấp phát các địa chỉ IP khi ports mới được tạo trên network.
 </div>

  <h4>Subnet Pools</h4>
 <div>
     Người dùng cuối thông thường có thể tạo các subnet với bất kì địa chỉ IP hợp lệ nào mà không bị hạn chế. Tuy nhiên, trong một vài trường hợp, sẽ là ổn hơn nếu như admin hoặc tenant định nghĩa trước một pool các địa chỉ để từ đó tạo ra các subnets được cấp phát tự động.
     <br>
     Sử dụng subnet pools sẽ ràng buộc những địa chỉ nào có thể được sử dụng bằng cách định nghĩa rằng mỗi subnet phải nằm trong một pool được định nghĩa trước. Điều đó ngăn chặn việc tái sử dụng địa chỉ hoặc bị chồng lấn hai subnets trong cùng một pool.
 </div>

  <h4>Ports</h4>
 <div>
     Là điểm kết nối để attach một thiết bị như card mạng của máy ảo tới mạng ảo. Port cũng được cấu hình các thông tin như địa chỉ MAC, địa chỉ IP để sử dụng port đó.
 </div>

  <h4>Router</h4>
 <div>
      Là thành phần logic chuyển tiếp các gói tin giữa các network. Nó cũng cung cấp L3 forwarding và NAT cho phép các máy ảo trên tenant network truy cập mạng ngoài. 
 </div>

  <h4>Security groups</h4>
 <div>
      Một security groups được coi như một firewall ảo cho các máy ảo để kiểm soát lưu lượng bên trong và bên ngoài router. Security groups hoạt động mức port, không phải mức subnet. Do đó, mỗi port trên một subnet có thể được gán với một tập hợp các security groups riêng. Nếu không chỉ định group cụ thể nào khi vận hành, máy ảo sẽ được gán tự động với default security group của project. Mặc định, group này sẽ hủy tất cả các lưu lượng vào và cho phép lưu lượng ra ngoài. Các rule có thể được bổ sung để thay đổi các hành vi đó.
      <br>
      Security group và các security group rule cho phép người quản trị và các tenant chỉ định loại traffic và hướng (ingress/egress) được phép đi qua port. Một security group là một container của các security group rules.
 </div>

   <h4>Open vSwitch</h4>
   <div>
       OpenvSwitch (OVS) là công nghệ switch ảo hỗ trợ SDN (Software-Defined Network), thay thế Linux bridge. OVS cung cấp chuyển mạch trong mạng ảo hỗ trợ các tiêu chuẩn <i>Netflow</i>, <i>OpenFlow</i>, <i>sFlow</i>. OpenvSwitch cũng được tích hợp với các switch vật lý sử dụng các tính năng lớp 2 như STP, LACP, 802.1Q VLAN tagging. OVS tunneling cũng được hỗ trợ để triển khai các mô hình network overlay như VXLAN, GRE.
   </div>

   <h4>L3 Agent</h4>
   <div>
       L3 agent là một phần của package <b>openstack-neutron</b>. Nó được xem như router layer3 chuyển hướng lưu lượng và cung cấp dịch vụ gateway cho network lớp 2. Các nodes chạy L3 agent không được cấu hình IP trực tiếp trên một card mạng mà được kết nối với mạng ngoài. Thay vì thế, sẽ có một dải địa chỉ IP từ mạng ngoài được sử dụng cho OpenStack networking. Các địa chỉ này được gán cho các routers mà cung cấp liên kết giữa mạng trong và mạng ngoài. Miền địa chỉ được lựa chọn phải đủ lớn để cung cấp địa chỉ IP duy nhất cho mỗi router khi triển khai cũng như mỗi floating IP gán cho các máy ảo.
       <ul>
           <li><b>DHCP Agent: </b> OpenStack Networking DHCP agent chịu trách nhiệm cấp phát các địa chỉ IP cho các máy ảo chạy trên network. Nếu agent được kích hoạt và đang hoạt động khi một subnet được tạo, subnet đó mặc định sẽ được kích hoạt DHCP.</li>
           <li><b>Plugin Agent: </b> Nhiều networking plug-ins được sử dụng cho agent của chúng, bao gồm OVS và Linux bridge. Các plug-in chỉ định agent chạy trên các node đang quản lý lưu lượng mạng, bao gồm các compute node, cũng như các nodes chạy các agent</li>
       </ul>
       <br><br>
       <img src="http://i.imgur.com/kBcsmJI.png">
       <br><br>
   </div>

   <h4>Modular Layer 2 (ML2)</h4>
   <div>
       Tham khảo thêm ở <a href="#">bài viết sau.</a>
   </div>

  <h4>Extensions</h4>
 <div>
      OpenStack Network service có khả năng mở rộng. Các extension phục vụ hai mục đích: cho phép tạo các tính năng mới trong API mà không yêu cầu thay đổi phiên bản và cho phép bổ sung chức năng phù hợp với nhà cung cấp cụ thể. Các ứng dụng có lấy danh sách các extensions có sẵn sử dụng phương thức GET trên <code>/extensions</code> URI. Chú ý đây là một request phụ thuộc vào phiên bản OpenStack, một extension sẵn sàng trong một API version có thẻ không sẵn sàng với phiên bản khác.
 </div>

  <h4>Layer 3 High Availability</h4>
  <div>
      OpenStack Networking bao gồm các router ảo nằm tập trung trên Network node - một server vật lý dùng để chứa các thành phần của mạng ảo. Các router ảo này sẽ chuyển hướng lưu lượng tới và từ các máy ảo, do đó nó rất quan trọng để duy trì kết nối liên tục trong môi trường cloud. Các server vật lý có thể bị ngừng hoạt động vì nhiều lý dó, điều này khiến cho các máy ảo bị mất kết nối.
      <br>
      OpenStack Networking do đó sử dụng <i>Layer 3 High Availability</i> để giảm thiểu những rủi ro như vậy bằng việc triển khai chuẩn giao thức VRRP bảo vệ các routers ảo và duy tri các địa chỉ floating IP. Với <i>Layer 3 High Availability</i>, các router ảo của một tenant được cấp phát ngẫu nhiên thông qua nhiều Network node vật lý, trong đó có một router sẽ được chỉ định làm <b>active router</b>, và các router khác phục vụ ở trạng thái chờ, sẵn sàng thay thế nếu Network node chứa <b>active router</b> bị ngừng hoạt động. 
  </div>

  <h4>HAproxy</h4>
  <div>
      HAproxy là thành phần có sẵn trong load balancer (cần phân biệt với LBaaS) làm nhiệm vụ phân tán các kết nối giữa tất cả các controllers đang sẵn sàng, để cung cấp giải pháp HA (High Availability - tính sẵn sàng cao). HAProxy vận hành ở layer 4, bởi vì nó dựa trên chỉ số port UDP/TCP được gán cho mỗi dịch vụ. VRRP sẽ xác định các kết nối HAProxy instance được gửi tới đầu tiên, sau đó HAProxy sẽ phân tán các kết nối tới các servers phía backend. Cấu hình này có thể cung cấp cân bằng tải, tính sẵn sàng cao.
  </div>

  <h4>Load Balancing-as-a-Service</h4>
  <div>
      Load Balancing-as-a-Service (LBaaS) cho phép OpenStack Networking phân tán các yêu cầu tới một cách đồng đều giữa các instances được chỉ định. Điều này đảm bảo tải được chia sẻ giữa các instances, cho phép sử dụng tài nguyên hệ thống hiệu quả hơn. Các yêu cầu tới được phân tán sử dụng các thuật toán cân bằng tải sau:
      <ul>
          <li><b>Round robin: </b>xoay vòng yêu cầu hiệu quả giữa nhiều instances.</li>
          <li><b>Source IP: </b>các yêu cầu tới từ một địa chỉ IP nguồn xác định sẽ được chuyển hướng nhất quán tới cùng một instances.</li>
          <li><b>Least connnections: </b>cấp phát các yêu cầu tới instance với số lượng kết nối active là nhỏ nhất.</li>
      </ul>
  </div>

  <h4>IPv6</h4>
  <div>
      OpenStack Neetworking hỗ trợ IPv6 cho các tenant network, cho phép cấp phát động các địa chỉ IPv6 cho các máy ảo (Stateful DHCPv6). OpenStack Networking cugnx có khả năng tích hợp với SLAAC trên các routers vật lý (Stateless Address Autoconfiguration), do đó các máy ảo có thể nhận được địa chỉ IPv6 từ hạ tầng DHCP có sẵn.
  </div>

  <h4>CIDR format(Classless Inter-Domain Routing - Định tuyến nội miền không phân lớp)</h4>
  <div>
      Các địa chỉ mạng có thể sử dụng theo hai cách
      <ul>
          <li>Sử dụng theo cách thông thường: các địa chỉ subnet theo truyền thống sẽ sử dụng địa chỉ mạng kèm theo subnet mask. Ví dụ:
          <ul>
              <li>Network address: 192.168.100.0</li>
              <li>Subnet mask: 255.255.255.0</li>
          </ul>
          </li>
          <li>Sử dụng định dạng CIDR: định dạng này rút gọn subnet mask thành số lượng bit active. Ví dụ: 192.168.100.0/24 tương đương với cặp 192.168.100.0 - 255.255.255.0</li>
      </ul>
  </div>
  
</div>

<h2><a name="hierachy">2. Hệ thống phân cấp các thành phần và dịch vụ</a></h2>
<ul>
    <li><h3><a name="server">2.1 Server</a></h3>
    Cung cấp API, quản lý các database, etc.
    </li>
    <li><h3><a name="plugin">2.2. Plug-ins</a></h3>
    Quản lý các agent.
    </li>
    <li><h3><a name="agent">2.3. Agents</a></h3>
    <ul>
        <li>Cung cấp kết nối layer 2/3 cho các máy ảo.</li>
        <li>Xử lý truyền thông giữa mạng ảo và mạng vật lý.</li>
        <li>Xử lý metadata, etc.</li>
    </ul>
    <h5>Layer 2 (Ethernet và Switching)</h5>
    <ul>
        <li>Linux bridge</li>
        <li>OVS</li>
    </ul>
    <h5>Layer 3 (IP và Routing)</h5>
    <ul>
        <li>L3</li>
        <li>DHCP</li>
    </ul>
    <h5>Metadata</h5>
    Tham khảo thêm tại đây: <a href="https://github.com/hocchudong/networking-team/blob/master/ThaiPH/OpenStack%20Neutron/ThaiPH_neutron_ml2_plug-in.md#23">ML2 plugin-Agent.</a>
    </li>
    <li><h3><a name="service">2.4 Services</a></h3>
    <h5>Các dịch vụ routing.</h5>
    <h5>VPNaaS</h5>
    <div>
        VPN-as-a-Service là một neutron extension tạo ra tập hợp các tính năng của VPN.
    </div>
    <h5>LBaaS</h5>
    <div>
        Load-Balancer-as-a-Service(LBaaS) API quy định và cấu hình nên các load balancers, được triển khai dựa trên HAProxy software load balancer.
    </div>
    <h5>FWaaS</h5>
    <div>
        FWaaS API là API thử nghiệm cho phép các nhà cung cấp kiểm thử trên networking của họ.
    </div>
    </li>
</ul>
<h2><a name="ref">3. Tham khảo</a></h2>
<div>
    [1] - <a href="http://docs.openstack.org/mitaka/networking-guide/intro-os-networking.html">http://docs.openstack.org/mitaka/networking-guide/intro-os-networking.html</a>
</div>