# Tích hợp OpenDaylight với OpenStack Mitaka
# Mục lục
### [1. Mô hình cài đặt](#topo)
### [2. Cấu hình](#config)
### [3. Tham khảo](#ref)
---

## <a name="topo"></a>1. Mô hình cài đặt

![topo](http://i.imgur.com/amlnSQa.png)

- Topology gồm 3 node cài ubuntu server 14.04:
	- OpenStack Mitaka CONTROLLER + NETWORK node: cài đặt các dịch vụ của cả 2 node OpenStack theo <a href="http://docs.openstack.org/mitaka/networking-guide/scenario-classic-ovs.html">scenario classic với OpenvSwitch.</a></li>
	- OpenStack Mitaka COMPUTE node cài đặt theo <a href="http://docs.openstack.org/mitaka/networking-guide/scenario-classic-ovs.html">scenario classic với OpenvSwitch.</a></li>
	- OpenDaylight node cài đặt <a href="https://nexus.opendaylight.org/content/groups/public/org/opendaylight/integration/distribution-karaf/0.4.2-Beryllium-SR2/distribution-karaf-0.4.2-Beryllium-SR2.zip">OpenDaylight Beryllium SR2.</a></li>

- Network Layout:
	- 2 node OpenStack, mỗi node cấu hình 3 card mạng:
		- External network: 172.16.69.0/24
		- Management network: 10.10.10.0/24
		- Data network: 10.10.20.0/24
  
	- OpenDaylight node cấu hình 2 card mạng:
		- External network
		- Management network

## <a name="config"></a>2. Cấu hình
- Bước 1: Cài đặt OpenDaylight

	- Trên máy cài OpenDaylight (IP: 10.10.10.106), cài đặt java và OpenDaylight Beryllium như sau:
	```sh
	sudo apt-get install openjdk-7-jdk
	wget https://nexus.opendaylight.org/content/groups/public/org/opendaylight/integration/distribution-karaf/0.4.2-Beryllium-SR2/distribution-karaf-0.4.2-Beryllium-SR2.tar.gz
	tar xvfz distribution-karaf-0.4.2-Beryllium-SR2.tar.gz
	cd distribution-karaf-0.4.2-Beryllium-SR2/bin
	./karaf
	```
	
	- Trên OpenDaylight shell(<code>opendaylight-user@root></code>), cài đặt các features cần thiết:
	```sh
	feature:install odl-ovsdb-openstack
	feature:install odl-dlux-core
	feature:install odl-dlux-all
	```
	
	- Trên bất kì node nào của OpenStack, kết nối thử tới OpenDaylight node như sau:        
    ```sh
    curl -u admin:admin http://10.10.10.106:8080/controller/nb/v2/neutron/networks
    # ket qua tuong tu nhu sau
    {
       "networks" : [ ]
    }
    ```

- Bước 2: Xóa toàn bộ các máy ảo và các network trong OpenStack
	- Bước này yêu cầu xóa toàn bộ các máy ảo và các network, router, subnet, floating IP đã tạo sử dụng Horizon hoặc commandline.
	- Sau đó trên OpenStack Controller ngắt dịch vụ <code>neutron-server</code>
	```sh
	sudo service neutron-server stop
	```

- Bước 3: Xóa neutron-openvswitch plugin trên các node OpenStack
	- Bước này thực hiện trên tất cả các node của OpenStack, thực hiện gỡ neutorn plugin agent và xóa cấu hình hiện tại của openvswitch rồi khởi động lại openvswitch.
	```sh
	sudo apt-get purge neutron-openvswitch-agent
	sudo service openvswitch-switch stop
	sudo rm -rf /var/log/openvswitch/
	sudo rm -rf /etc/openvswitch/conf.db
	sudo mkdir /var/log/openvswitch/
	sudo service openvswitch-switch start
	sudo ovs-vsctl show
	```	
    	- Sau khi khởi động lại OVS, kết quả tương tự như sau:
	```sh
	root@controller:~# ovs-vsctl show
	265911e9-7cdc-4f0a-8965-fdff0b804eb6
		ovs_version: "2.5.0"
	```	
	- Tiếp đó, với mỗi OpenStack node, lấy địa chỉ IP tunnel network bổ sung vào cấu hình của OpenvSwitch. Ví dụ thực hiện trên OpenStack Controller node, lấy ID của OpenvSwitch từ lệnh <code>ovs-vsctl show</code> ta được: <code>265911e9-7cdc-4f0a-8965-fdff0b804eb6</code>. Địa chỉ của tunnel interface với OpenStack Controller node là: <code>10.10.20.193</code>. Có được 2 số liệu này, thực hiện cấu hình cho OpenvSwitch như sau:
	```sh
	sudo ovs-vsctl set Open_vSwitch 265911e9-7cdc-4f0a-8965-fdff0b804eb6 other_config={'local_ip'='10.10.20.193'}
	```	
	- Kết nối OVS tới OpenDaylight controller:
	```sh
	sudo ovs-vsctl set-manager tcp:10.10.10.106:6640
	```	
	- Sau bước này thực hiện kiểm tra các bridge và port trên OpenvSwitch:
	```sh
	$ ovs-vsctl show
	265911e9-7cdc-4f0a-8965-fdff0b804eb6
		Manager "tcp:10.10.10.106:6640"
			is_connected: true
		Bridge br-int
			Controller "tcp:10.10.10.106:6653"
				is_connected: true
			fail_mode: secure
			Port br-int
				Interface br-int
					type: internal
		ovs_version: "2.5.0"
	```	
        - Chú ý nếu kết nối thành công sẽ có thông báo `is_connected: true` như trên, và đảm bảo OpenDaylight tự động tạo ra __integration bridge__ `br-int` như trên. Thực hiện tương tự với Compute node.

- Bước 4: Cấu hình external network trên OpenStack Network node
	- Bước này với mô hình OpenStack 3 node (Controller, Network, Compute) thực hiện trên Network node, với bài lab này cũng chính là cấu hình Controller node. Thực hiện tạo external bridge:
	```sh
	ovs-vsctl add-br br-ex
	ovs-vsctl add-port br-ex eth0
	ifconfig eth0 0
	ifconfig br-ex 172.16.69.193/24
	route add default gw 172.16.69.1
	```
	
	- Bước trên cấu hình gán eth0 làm port trên external bridge rồi gán lại địa chỉ IP của card eth0 cho external bridge br-ex. Để cấu hình này không bị mất sau khi khởi động lại Controller node, ghi lại cấu hình vào trong file `/etc/network/interfaces` với nội dung tương tự như sau:
	```sh
	# This file describes the network interfaces available on your system
	# and how to activate them. For more information, see interfaces(5).
	
	# The loopback network interface
	auto lo
	iface lo inet loopback
	
	# The primary network interface
	# external network
	auto br-ex
	iface br-ex inet static
	address 172.16.69.193/24
	gateway 172.16.69.1
	dns-nameservers 8.8.8.8
	
	auto eth0
	iface eth0 inet manual
	up ifconfig $IFACE 0.0.0.0 up
	up ip link set $IFACE promisc on
	down ip link set $IFACE promisc off
	down ifconfig $IFACE down
	
	# management network
	auto eth1
	iface eth1 inet static
	address 10.10.10.193/24
	
	# data network
	auto eth2
	iface eth2 inet static
	address 10.10.20.193/24
	```

- Bước 5: Cấu hình file `ml2_conf.ini` trên OpenStack Controller node
	- Chỉnh sửa file `/etc/neutron/plugins/ml2/ml2_conf.ini` trên Controller node của OpenStack.
        - Trên Controller node
		```sh
		$ sudo vi /etc/neutron/plugins/ml2/ml2_conf.ini
		[ml2]
		type_drivers = flat,vlan,vxlan
		tenant_network_types = vxlan
		mechanism_drivers = opendaylight
		extension_drivers = port_security
		
		[ml2_type_flat]
		flat_networks = provider
		
		[ml2_type_vxlan]
		vni_ranges = 1:1000
		
		[ml2_odl]
		username = admin
		password = admin
		url = http://10.10.10.106:8080/controller/nb/v2/neutron
		
		[securitygroup]
		firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
		enable_ipset = True
		```

- Bước 6: Cấu hình l3 agent trên Controller node
	- Trên Controller node cấu hình l3 agent như sau:
	```sh
	$ sudo vi /etc/neutron/l3_agent.ini
	[DEFAULT]
	interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
	external_network_bridge = br-ex
	```

- Bước 7: Reset neutron database trên Controller node
	- Trên Controller node, thực hiện các câu lệnh sau để reset lại neutron database với cấu hình mới, chú ý file thiết lập biến môi trường cho OpenStack, ở đây là `admin-openrc`.
	```sh
	$ source admin-openrc
	$ mysql -u root -p
	MariaDB [(none)]>DROP DATABASE neutron;
	MariaDB [(none)]>CREATE DATABASE neutron;
	MariaDB [(none)]>GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' \
	IDENTIFIED BY 'Welcome123';
	MariaDB [(none)]>GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' \
	IDENTIFIED BY 'Welcome123';
	MariaDB [(none)]>EXIT;
	$ sudo su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
	```

- Bước 8: Khởi động lại neutron trên các node OpenStack
	- Trên Controller node:
	```sh
	sudo service neutron-server restart
	sudo service openvswitch-switch restart
	sudo service neutron-l3-agent restart
	sudo service neutron-dhcp-agent restart
	sudo service neutron-metadata-agent restart
	```
	
	- Trên Compute node:
	```sh
	sudo service openvswitch-switch restart
	```

- Bước 9: Cài đặt networking_odl python module
	- Bước này cài đặt `networking_odl` trên Controller node để OpenStack làm việc với OpenDaylight (thay vì sử dụng `neutron-openvswitch-agent`). Sau đó khởi động lại `neutron-server`.
	```sh
	sudo apt-get install python-networking-odl
	service neutron-server restart
	```

- Bước 10: Kiểm tra
	- Bước này tạo ra external và internal network kiểm tra hoạt động của mô hình sử dụng OpenStack tích hợp OpenDaylight. Thực hiện các câu lệnh sau trên OpenStack Controller node.
	```sh
	source admin-openrc
	neutron net-create ext-net --router:external --provider:physical_network provider --provider:network_type flat
	neutron subnet-create ext-net 172.16.69.0/24 --name ext-subnet --allocation-pool start=172.16.69.143,end=172.16.69.149 --disable-dhcp --gateway 172.16.69.1
	neutron net-create demo-net
	neutron subnet-create demo-net 192.168.1.0/24 --name demo-subnet --gateway 192.168.1.1 
	neutron router-create demo-router 
	neutron router-interface-add demo-router demo-subnet
	neutron router-gateway-set demo-router ext-net
	```
	
	- Đợi khoảng 1 phút, kiểm tra kết nối tới router gateway của __demo-router__(router ảo do l3 agent tạo ra). Kết quả thành công tương tự như sau.
	```sh
	$ ping 172.16.69.143
	PING 172.16.69.143 (172.16.69.143) 56(84) bytes of data.
	64 bytes from 172.16.69.143: icmp_seq=1 ttl=64 time=0.423 ms
	64 bytes from 172.16.69.143: icmp_seq=2 ttl=64 time=0.088 ms
	64 bytes from 172.16.69.143: icmp_seq=3 ttl=64 time=0.090 ms
	^C
	--- 172.16.69.143 ping statistics ---
	3 packets transmitted, 3 received, 0% packet loss, time 1998ms
	rtt min/avg/max/mdev = 0.088/0.200/0.423/0.157 ms
	```

## <a name="ref"></a>3. Tham khảo

- [1] - <a href="https://github.com/netgroup-polito/frog4-openstack-do/blob/master/README_OPENSTACK.md">https://github.com/netgroup-polito/frog4-openstack-do/blob/master/README_OPENSTACK.md</a>

- [2] - <a href="http://sciencecloud-community.cs.tu.ac.th/?p=238">http://sciencecloud-community.cs.tu.ac.th/?p=238</a>

- [3] - <a href="http://superuser.openstack.org/articles/open-daylight-integration-with-openstack-a-tutorial">http://superuser.openstack.org/articles/open-daylight-integration-with-openstack-a-tutorial</a>
