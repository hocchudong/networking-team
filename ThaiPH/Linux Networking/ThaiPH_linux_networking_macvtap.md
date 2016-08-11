# Linux networking - Macvtap
# Mục lục
<h3><a href="#macvlan">1. Macvlan</a></h3>
<h3><a href="#tap">2. Tap</a></h3>
<h3><a href="#mavtap">3. Macvtap</a></h3>
<ul>
    <li><a href="#vepa">3.1. VEPA mode</a></li>
    <li><a href="#bridge">3.2. Bridge mode</a></li>
    <li><a href="#private">3.3. Private mode</a></li>
    <li><a href="#passthru">3.4. Passthrough</a></li>    
</ul>

<h3><a href="#ref">4. Tham khảo</a></h3>

---

<h2><a name="macvlan">1. Macvlan</a></h2>
<div>
    <b>Mavlan</b> driver là một Linux kernel driver tách biệt được Macvtap sử dụng. Mavlan cho phép tạo các card mạng ảo (VIF - virtual network interfaces) trực tiếp trên card mạng vật lý. Mỗi card mạng ảo có địa chỉ MAC riêng tách biệt với địa chỉ MAC của card mạng vật lý. Các frames được gửi tới hoặc được nhận từ card mạng ảo mà được map với card vật lý - hay lower interface.
    <br><br>
    <img src="http://hicu.be/wp-content/uploads/2016/03/linux-macvlan.png">
    <br><br>
</div>
<h2><a name="tap">2. Tap</a></h2>
<div>
    <b>Tap</b> interface là một card mạng dưới dạng phần mềm. Thay vì phải đưa frames tới hoặc nhận frame từ card Ethernet vật lý, các frames này được đọc và ghi bởi chương trình thuộc <b>user space</b>. Kernel sẽ cho phép kích hoạt các <b>tap</b> interface thông qua file <code>/dev/tapN</code>, trong đó N là số hiệu của card mạng.
    <br><b>Tap</b> interface thường đi kèm với hai công nghệ switch ảo trong Linux là <b>linux bridge</b> và <b>openvswitch</b>. Trong đó tap interfaces chính là các cổng tạo trên các switch ảo để các máy ảo gắn vào(ví dụ trên linux bridge thường được đặt tên là vnetN - với N là số hiệu cổng). <b>Tap</b> interface làm việc với các Ethernet frames (khác với Tun interfaces làm việc với các IP frames).
    <br><br>
    <img src="http://imgur.com/1mvTJ8M.png">
    <br><br>
</div>
<h2><a name="mavtap">3. Macvtap</a></h2>
<b>Macvtap</b> interfaces kết hợp thuộc tính của hai công nghệ <b>macvlan</b> và <b>tap</b>, nó là một card mạng ảo tương tự như <b>tap</b> và tạo trên một card mạng vật lý. 
<br><br>
<img src="https://seravo.fi/wp-content/uploads/2012/10/tap-300x221.png">
<br><br>
Trước hết kiểm tra xem linux kernel có hỗ trợ <b>macvtap</b> không, thực hiện kiểm tra như sau:
<pre>
    <code>
modprobe macvlan
lsmod | grep macvlan
    </code>
</pre>
Kết quả trả về thông báo kernel hỗ trợ <b>macvtap</b> sẽ tương tự như sau:
<pre>
    <code>
macvlan                24576  1 macvtap
    </code>
</pre>
Tiến hành tạo macvtap interface <b>macvtap0</b> như sau:
<pre>
    <code>
ip link add link eth0 name macvtap0 type macvtap
    </code>
</pre>
Kiểm tra <b>macvtap0</b> interface vừa tạo:
<pre>
    <code>
ip link | grep macvtap0

# ket qua tuong tu nhu sau
5: macvtap0@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 500
    </code>
</pre>
Thiết bị này sẽ tương tứng với 1 macvtap interface với chỉ số 5 chỉ định trong file <code>/dev/tap5</code>:
<pre>
    <code>
ls -l /dev | grep tap
# ket qua se tuong tu nhu sau
crw-------  1 root root    247,   1 Aug  9 20:32 tap5
    </code>
</pre>
Một chương trình thuộc <b>user space</b> có thể mở file thiết bị này và sử dụng nó để gửi và nhận các Ethernet frames thông qua nó. Khi kernel truyền một frame qua interface macvtap0, thay vì gửi nó tới card mạng vật lý, nó sẽ được đọc từ file này bởi một chương trình thuộc <b>userspace</b>. Tương tự như vậy, khi một chương trình thuộc <b>user space</b> ghi nội dung lên một Ethernet frame tới file <code>/dev/tap5</code>, các đoạn mã networking của kernel sẽ thấy được frame bởi vì nó được nhận thông qua thiết bị <b>macvtap0</b>.
<br>Chương trình thuộc <b>user space</b> nhắc tới ở đây thường là một emulator điển hình như QEMU, với các card mạng ảo được gán cho các máy ảo. Khi QEMU đọc một Ethernet frame sử dụng tệp mô tả, nó sẽ giả lập việc mà card mạng thật làm. 
<br>
<b>Macvtap</b> device có thể thực hiện chức năng ở một trong 4 modes: Virtual Ethernet Port Aggregator (VEPA) mode, Bridge mode, Private mode và Passthrough mode.
<ul>
    <li><h3><a name="vepa">3.1. VEPA</a></h3>
    Trong chế độ này, dữ liệu giữa các endpoints (các VM trên máy vật lý) trên cùng một card mạng vật lý (card mạng mà các macvtap interface tạo trên đó) được gửi thông qua card này tới switch vật lý card đó gắn vào. Chế này yêu cầu switch ngoài phải hỗ trợ "Reflective Relay" hay "hairpin mode", nghĩa là switch có thể gửi trả lại một frame trên chính port mà nhận frame đó. Tuy nhiên, hầu hết các switch ngày nay đều không hỗ trợ chế độ này.
    <br><br>
    <img src="https://seravo.fi/wp-content/uploads/2012/10/hairpin-290x300.png">
    <br><br>
    </li>
    <li><h3><a name="bridge">3.2. Bridge</a></h3>
    Ở chế độ này, các endpoints có thể giao tiếp trực tiếp với nhau mà không phải gửi dữ liệu thông qua <b>lower device</b> (card vật lý để tạo các macvtap interface). Việc sử dụng chế độ này không yêu cầu switch vật lý phải hỗ trợ "Reflective Relay".
    <h4>Demo</h4>
    <div>
    Ping thử hai máy thiết lập card mạng <code>macvtap</code> chế độ <code>bridge</code>. Kết quả ping thành công
         <ul>
             <li>Thiết lập:
             <br><br>
             <img src="http://i.imgur.com/5nAo486.png">
             <br><br>
             </li>
             <li>Ping thử:
             <br><br>
             <img src="http://i.imgur.com/2MTLMyn.png">
             <br><br>
             </li>

         </ul>
    </div>
    </li>

    <li><h3><a name="private">3.3. Private</a></h3>
    Trong chế độ này, các node trên cùng 1 <b>lower device</b> có thể không bao giờ "nói chuyện" được với nhau (trừ khi đi qua một external gateway hoặc external router), không liên quan tới việc switch vật lý có hỗ trợ "Reflective Relay" hay không. Chế độ này được sử dụng khi có yêu cầu cô lập các máy ảo kết nối tới các endpoints khác.
    <h4>Demo</h4>
    <div>Hai máy thiết lập card mạng <code>macvtap</code> chế độ <code>private</code> không ping được với nhau: 
    <ul>
        <li>Thiết lập:
<br><br>
<img src="http://i.imgur.com/gBT90ON.png">
<br><br>
        </li>
        <li>Ping:
<br><br>
<img src="http://i.imgur.com/Kwe33Bn.png">
<br><br>
        </li>
    </ul>

    </div>

    </li>
    <li><h3><a name="passthru">3.4. Passthrough</a></h3>
    Chế độ này sẽ gán trực tiếp một Virtual Function của card mạng hỗ trợ <b>SR-IOV</b> tới một VM mà không làm mất khả năng <b>migration</b>. Tất cả các gói tin được gửi tới VF/IF của thiết bị mạng đã được cấu hình. Chế độ này phụ thuộc vào các yêu cầu thêm hay hạn chế bớt của cả phần cứng lẫn phần mềm.
    <br>
    <i><b>SR-IOV - Single Root Input/Output Virtualization</b>
    <div>
        SR-IOV là công nghệ ảo hóa cho phép một thiết bị PCIe được chia thành nhiều thiết bị PCIe vật lý trên đó, phân tách việc truy cập tới tài nguyên trên thiết bị này. SR-IOV đưa ra các khái niệm:
        <ul>
        <li><b>PFs -  Physical functions</b>:  là chức năng chính của thiết bị, mang đầy đủ tính năng của thiết bị PCIe, nghĩa là chúng có thể tìm kiếm, quản lý và thực hiện các tác vụ hệt như các thiết bị PCIe thực sự, đồng thời cũng có khả năng cấu hình và kiểm soát thiết bị PCIe thông qua PF và PF hoàn toàn có khả năng đưa dữ liệu đi ra hay đi vào thiết bị</li>
        <li><b>VFs - Virtual functions</b>: tương tự như PFs nhưng hạn chế hơn PFs, về cơ bản chúng chỉ có khả năng đưa dữ liệu vào ra, không thể cấu hình PCIe qua VFs bởi lẽ các VFs được kết nối với PF ở bên dưới nó. Ví dụ: một SR-IOV NIC có 4 cổng có thể coi như 4 thiết bị đơn cổng. Mỗi thiết bị đơn cổng này có thể cấu hình để có tới 256 VFs (hay 256 NICs ảo đơn cổng), và về mặt lý thuyết ta sẽ có tổng cộng 1024 VFs.
        </li>
        </ul>
    </div>
        Ảo hóa SR-IOV trên các card mạng vật lý cho phép Virtual Machine Manager - VMM của hypervisor map các VFs tới không gian cấu hình của máy ảo, giúp các interfaces của máy ảo kết nối trực tiếp tới VFs, nâng cao hiệu năng của máy ảo, giảm overhead mà vẫn đảm bảo live migration(khi sử dụng ảo hóa Hypervisor-based thì việc giao tiếp giữa thiết bị vật lý tới máy ảo hay <b>guest os</b> phải thông qua <b>host os</b>, cụ thể hơn là phải thông qua các driver trên hypervisor của host os, còn nếu sử dụng ảo hóa kết hợp giải pháp <b>device passthrough</b> thì gặp vấn đề về <b>live-migration</b>).
    </i>
    </li>    

</ul>
<div>
    Nhìn lại chế độ VEPA, điều gì khiến cho chế độ này trở thành 1 ý tưởng tốt khi gửi frames ra ngoài host tới switch vật lý, rồi lại bị gửi trở lại card vật lý từ cùng một port trên switch nơi mà frame đó được nhận vào? VEPA mode thực ra đã đơn giản hóa tác vụ chuyển mạch cho máy host bằng việc để switch vật lý bên ngoài làm nhiệm vụ chuyển mạch - chức năng chủ đạo mà switch đảm nhận.  Hơn nữa, các quản trị viên của hệ thống mạng có thể giám sát được lưu lượng giữa các máy ảo bằng cách sử dụng các công cụ quen thuộc trên một switch làm nhiệm vụ quản lý, tận dụng được các tính năng bảo mật, sàng lọc và quản lý của switch. (trong khi việc này không thể thực hiện nếu như dữ liệu không đi ra switch).
    <br>
    Switch truyền thống không hỗ trợ <b>Reflective Relay</b> vì giao thức STP (Spanning Tree Protocol) ngăn cản chế độ này và bởi vì trước khi có công nghệ ảo hóa thì việc gửi trả lại frame như vậy không hề có ý nghĩa.
</div>

<h2><a name="ref">4. Tham khảo</a></h2>
[1] - <a href="http://hicu.be/bridge-vs-macvlan">http://hicu.be/bridge-vs-macvlan</a>
<br>
[2] - <a href="https://seravo.fi/2012/virtualized-bridged-networking-with-macvtap">https://seravo.fi/2012/virtualized-bridged-networking-with-macvtap</a>
<br>
[3] - <a href="https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Virtualization_Administration_Guide/sect-attch-nic-physdev.html">https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Virtualization_Administration_Guide/sect-attch-nic-physdev.html</a>
<br>
[4] - <a href="http://virt.kernelnewbies.org/MacVTap">http://virt.kernelnewbies.org/MacVTap</a>
<br>
[5] - <a href="https://www.juniper.net/documentation/en_US/junos16.1/topics/concept/bridging-reflective-relay-qfx-series.html">https://www.juniper.net/documentation/en_US/junos16.1/topics/concept/bridging-reflective-relay-qfx-series.html</a>
<br>
[6] - <a href="http://www.innervoice.in/blogs/2013/12/08/tap-interfaces-linux-bridge/">http://www.innervoice.in/blogs/2013/12/08/tap-interfaces-linux-bridge/</a>
<br>
[7] - <a href="http://backreference.org/2010/03/26/tuntap-interface-tutorial/">http://backreference.org/2010/03/26/tuntap-interface-tutorial/</a>
<br>
[8] - <a href="http://networkstatic.net/configuring-macvlan-ipvlan-linux-networking/">http://networkstatic.net/configuring-macvlan-ipvlan-linux-networking/</a>
<br>
[9] - <a href="http://suhu.dlinkddns.com/Presentation/20150203/">http://suhu.dlinkddns.com/Presentation/20150203/</a>

