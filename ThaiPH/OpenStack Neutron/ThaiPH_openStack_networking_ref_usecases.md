# OpenStack Networking usecases tham khảo
# Mục lục
<h3><a href="#1">1. Single flat network</a></h3>
<h3><a href="#2">2. Multiple flat networks</a></h3>
<h3><a href="#3">3. Mixed flat and private networks</a></h3>
<h3><a href="#4">4. Provider router with private networks</a></h3>
<h3><a href="#5">5. Per-tenant routers with private networks</a></h3>
<h3><a href="#ref">6. Tham khảo</a></h3>

---

<h2><a name="1">1. Single flat network</a></h2>
<div>
    <br><br>
    <img src="http://docs.openstack.org/icehouse/training-guides/content/figures/13/a/figures/image34.png">
    <br><br>
    Trong mô hình này, openstack neutron sẽ tạo ra 1 "shared network", có nghĩa là mọi tenant có thể thấy được network này thông qua OpenStack Networking API. Các VMs của các tenant có một NIC duy nhất và nhận một địa chỉ IP tĩnh từ subnet (hoặc các subnet) kết nối với mạng đó. Mô hình này tương tự như FlatManager và FlatDHCP Manager khi sử dụng <b>nova-network</b> hay cung cấp bởi OpenStack Compute. Mô hình này không hỗ trợ floating IPs.
    <br>
    Trong usecase này, neutron đóng vai trò "provider network", được tạo bởi quản trị viên và ánh xạ trực tiếp với một mạng vật lý trên datacenter. Điều này cho phép nhà cung cấp sử dụng router vật lý trên datacenter làm gateway cho các VMs ra ngoài internet. Với mỗi subnet trên một mạng ngoài, cấu hình gateway trên router vật lý phải thực hiện thủ công để cung cấp kết nối ra ngoài internet cho cloud OpenStack.
</div>
<h2><a name="2">2. Multiple flat networks</a></h2>
<div>
    <br><br>
    <img src="http://docs.openstack.org/icehouse/training-guides/content/figures/13/a/figures/image35.png">
    <br><br>
    Mô hình này tương tự mô hình <b>single flat network</b>, chỉ khác một điểm là các VMs của các tenant có thể thamm gia nhiều <b>shared networks</b>, và có thể lựa chọn "shared network" nào sẽ tham gia vào.
</div>
<h2><a name="3">3. Mixed flat and private networks</a></h2>
<div>
    <br><br>
    <img src="http://docs.openstack.org/icehouse/training-guides/content/figures/13/a/figures/image36.png">
    <br><br>
    Usecase này mở rộng của các usecase flat network ở trên, trong đó các tenant ngoài việc các tenant VMs chia sẻ chung một "shared network" để kết nối internet và kết nối với nhau, mỗi tenant có thể tạo thêm 1 private network để kết nối các VMs nội bộ tenant đó. Điều này cho phép mô hình sử dụng VM làm gateway cung cấp các dịch vụ như routing, NAT, load balacing.
</div>
<h2><a name="4">4. Provider router with private networks</a></h2>
<div>
    <br><br>
    <img src="http://docs.openstack.org/icehouse/training-guides/content/figures/13/a/figures/image37.png">
    <br><br>
    Usecase này cung cấp cho mỗi tenant một hoặc nhiều private networks, và kết nối ra các mạng ngoài như internet sử dụng OpenStack Networking router. Trong trường hợp này, các tenant chỉ có thể "thấy" được network private gán cho tenant đó mà không thấy được neutron router vì router thuộc quyền kiểm soát của người quản trị.
    <br>
    Mô hình hỗ trợ cho các VMs sử dụng "floating IPs" - là địa chỉ mà router sẽ ánh xạ từ địa chỉ public trên mạng ngoài sang địa chỉ "fixed IPs" trên private network của tenant. Các VM không có địa chỉ IPs vẫn có thể kết nối ra mạng ngoài bởi vì <b>provider router</b> thực hiện cơ chế SNAT ra địa chỉ IP ngoài của router.
    <br>
    Router ảo cung cấp kết nối lớp 3 giữa các private network, nghĩa là các VMs của các tenant có thể truyền thông nhau trừ khi sử dụng cơ chế lọc trong security group, các tenant network không được sử dụng địa chỉ IPs trùng nhau. Do đó, việc tạo các private network cho các tenant do quản trị cloud thực hiện để tránh tính trạng đó.
</div>
<h2><a name="5">5. Per-tenant routers with private networks</a></h2>
<div>
    <br><br>
    <img src="http://docs.openstack.org/icehouse/training-guides/content/figures/13/a/figures/image38.png">
    <br><br>
    Kịch bản này mở rộng hơn so so với mô hình trên, trong đó mỗi tenant có thể nhận ít nhất một router, và được phép truy cập vào OpenStack Networking API để tạo thêm router. Tenant có thể tạo network của riêng học, và uplink các networks này tới một router. Mô hình này cho phép các ứng dụng đa lớp do tenant định nghĩa, mỗi lớp sẽ nằm trên network riêng biệt đằng sau router. Bởi vì có nhiều routers, các tenant subnets có thể chồng lấn nhau mà không lo bị xung đột, và kết nối ra các mạng ngoài thực hiện thông qua SNAT hoặc Floating IPs. Mỗi router uplink và floating IP được cấp phát từ subnet mạng ngoài.
</div>
<h2><a name="ref">6. Tham khảo</a></h2>
<div>
    [1] - <a href="http://docs.openstack.org/icehouse/training-guides/content/operator-network-node.html">http://docs.openstack.org/icehouse/training-guides/content/operator-network-node.html</a>
    <br>
    [2] - <a href="http://www.slideshare.net/lowescott/an-introduction-to-openstack-networking">http://www.slideshare.net/lowescott/an-introduction-to-openstack-networking</a>
</div>