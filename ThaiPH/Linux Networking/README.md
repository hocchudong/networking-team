# Ghi chép về linux networking
# Mục lục
<h3><a href="https://github.com/hocchudong/networking-team/blob/master/ThaiPH/Linux%20Networking/ThaiPH_linux_networking_macvtap.md">1. Lý thuyết macvlan, tap và macvtap</a></h3>
<h3><a href="https://github.com/hocchudong/networking-team/blob/master/ThaiPH/Linux%20Networking/ThaiPH_docker_macvlan_bridge.md">2. Lab macvlan bridge</a></h3>
<h3><a href="https://github.com/hocchudong/networking-team/blob/master/ThaiPH/Linux%20Networking/ThaiPH_docker_macvlan_VLAN.md">3. Lab multiple docker macvlan networks trên 802.1Q trunk VLANs</a></h3>
<h3><a href="https://github.com/hocchudong/networking-team/blob/master/ThaiPH/Linux%20Networking/ThaiPH_macvlan_vs_ipvlan.md">4. So sánh Macvlan và Ipvlan</a></h3>

---

# Ghi chú
<div>
    Repo này tập hợp lý thuyết và các bài lab về các công nghệ network sử dụng trong ảo hóa kvm, cụ thể hơn:
    <ul>
        <li>1. Lý thuyết và so sánh giữa macvlan, tap và macvtap sử dụng kết hợp với nền tảng ảo hóa kvm để cung cấp kết nối mạng cho các VM</li>
        <li>2. Bài lab về macvlan bridge. Về cơ bản, macvlan và macvtap (phát triển dựa trên việc kết hợp macvlan và tap) đều có 4 chế độ hoạt động: VEPA, private, bridge, passthrough. Bài lab này lab macvlan ở chế độ bridge, sử dụng macvlan driver của Docker - công nghệ ảo hóa dựa trên containers.</li>
        <li>3. Bài lab mở rộng sử dụng macvlan driver của Docker, kết nối container giữa các host, trong đó có tách biệt các macvlan network trên các VLAN khác nhau.</li>
        <li>4. So sánh macvlan và ipvlan</li>
    </ul>
    Chi tiết hơn được trình bày trong mô tả của các bài lab.
</div>

