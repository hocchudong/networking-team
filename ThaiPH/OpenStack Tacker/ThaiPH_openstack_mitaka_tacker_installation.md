# Cài đặt Tacker trên OpenStack Mitaka
# Mục lục
<h3><a href="#req">1. Yêu cầu</a></h3>
<h3><a href="#cfg">2. Cài đặt và cấu hình</a></h3>
<h3><a href="#check">3. Kiểm tra kết quả cài đặt</a></h3>
<h3><a href="#ref">3. Tham khảo</a></h3>

---
<i><b>Chú ý: </b>Bài lab này cài đặt Tacker trên OpenStack <code>CONTROLLER NODE</code>.</i>
<h2><a name="req">1. Yêu cầu</a></h2>
<div>
    <ol>
        <li>Cài đặt OpenStack Mitaka với các component: Keystone, Glance, Nova, Neutron, Heat, Horizon theo mô hình <a href="http://docs.openstack.org/liberty/networking-guide/scenario-classic-ovs.html">classic openvswitch.</a> Mô hình sử dụng 2 node: 
            <ul>
                <li>CONTROLLER + NETWORK</li>
                <li>COMPUTE</li>
            </ul>
        </li>
        <li>Tạo script thiết lập biến môi trường cho client trong file <code>admin-openrc</code> với nội dung tương tự như sau:
<pre><code>
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=$1
export OS_USERNAME=admin
export OS_PASSWORD=Welcome123
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
</code></pre>
        </li>
        <li>Cài đặt thêm các gói cần thiết:
<pre><code>sudo apt-get install python-pip git</code></pre>
        </li>
        <li>Chỉnh sửa trong file <code>/etc/neutron/plugins/ml2/ml2_conf.ini</code> như sau:
<pre><code>
[ml2]
extension_drivers = port_security
</code></pre>
        </li>
    </ol>
</div>

<h2><a name="cfg">2. Cài đặt và cấu hình</a></h2>
<div>
    <h3>Cài đặt Tacker server</h3>
    <ol>
        <li>Tạo <code>tacker</code> database và user
<pre><code>
mysql -uroot -p
CREATE DATABASE tacker;
GRANT ALL PRIVILEGES ON tacker.* TO 'tacker'@'localhost' \
    IDENTIFIED BY 'Welcome123';
GRANT ALL PRIVILEGES ON tacker.* TO 'tacker'@'%' \
    IDENTIFIED BY 'Welcome123';
</code></pre>
        Thay <code>Welcome123</code> bằng password tương ứng để thiết lập permission cho database <code>tacker</code>.
        </li>
        <li>Tạo users, roles và endpoints:
            <ul>
                <li>Thiết lập biến môi trường:
<pre><code>
source admin-openrc admin
</code></pre>
                </li>
                 <li>Tạo project <code>nfv</code>
<pre><code>
openstack project create --domain default --description "NFV Project" nfv
</code></pre>
        </li>
        <li>Tạo các user <code>tacker</code> và <code>nfv_user</code>
<pre><code>
openstack user create --domain default --password "Welcome123" tacker
openstack user create --domain default --password "Welcome123" nfv_user
</code></pre>
        Thay đổi giá trị password cho phù hợp.
        </li>
        <li>Tạo role <code>advsvc</code> và <code>_member_</code>, gán role cho các user <code>tacker</code>, <code>nfv_user</code>, <code>admin</code> trên các project <code>service</code> và <code>nfv</code>:
<pre><code>
# create role
openstack role create advsvc
openstack role create _member_

# role assignment
openstack role add --project service --user tacker admin
openstack role add --project service --user tacker advsvc
openstack role add --project nfv --user nfv_user admin
openstack role add --project nfv --user nfv_user advsvc
openstack role add --project nfv --user admin _member_
</code></pre>
        </li>
        <li>Tạo tacker service
<pre><code>
openstack service create --name tacker --description "Tacker Project" nfv-orchestration
</code></pre>
        </li>
        <li>Tạo các endpoints truy cập tacker service
<pre><code>
openstack endpoint create --region RegionOne nfv-orchestration public http://controller:8888/
openstack endpoint create --region RegionOne nfv-orchestration internal http://controller:8888/
openstack endpoint create --region RegionOne nfv-orchestration admin http://controller:8888/
</code></pre>
        </li>
            </ul>
        </li>

        <li>Clone tacker repo và chỉnh sửa file <code>requirements.txt</code>
<pre><code>
git clone -b stable/mitaka https://github.com/openstack/tacker
cd tacker
sed -i 's/Routes!=2.0,!=2.3.0,>=1.12.3;python_version!='2.7'/#Routes!=2.0,!=2.3.0,>=1.12.3;python_version!='2.7'/g' requirements.txt
</code></pre>
        </li>
        <li>Cài đặt tacker server
<pre><code>
pip install -r requirements.txt
pip install tosca-parser
python setup.py install
</code></pre>
        </li>
        <li>Tạo file log và cache cho <code>tacker</code>:
<pre><code>
mkdir -p /var/log/tacker
mkdir -p /var/cache/tacker
</code></pre>
        </li>
        <li>Chỉnh sửa file cấu hình <code>/usr/local/etc/tacker/tacker.conf</code>:
<pre><code>
cfg=/usr/local/etc/tacker/tacker.conf
DEFAULT_PASS=Welcome123

cat << EOF > $cfg
[DEFAULT]
logging_exception_prefix = %(color)s%(asctime)s.%(msecs)03d TRACE %(name)s %(instance)s
logging_debug_format_suffix = from (pid=%(process)d) %(funcName)s %(pathname)s:%(lineno)d
logging_default_format_string = %(asctime)s.%(msecs)03d %(color)s%(levelname)s %(name)s [-%(color)s] %(instance)s%(color)s%(message)s
logging_context_format_string = %(asctime)s.%(msecs)03d %(color)s%(levelname)s %(name)s [%(request_id)s %(user_name)s %(project_name)s%(color)s] %(instance)s%(color)s%(message)s
debug = true
#verbose =  True

auth_strategy = keystone
policy_file = /usr/local/etc/tacker/policy.json
state_path = /var/lib/tacker

service_plugins = vnfm,nfvo
notification_driver = tacker.openstack.common.notifier.rpc_notifier

[oslo_concurrency]
lock_path = \$state_path/lock

[keystone_authtoken]
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
auth_plugin = password
project_domain_name = default
user_domain_name = default
project_name = service
username = tacker
password = $DEFAULT_PASS

[agent]
root_helper = sudo /usr/local/bin/tacker-rootwrap /usr/local/etc/tacker/rootwrap.conf

[database]
connection = mysql+pymysql://tacker:$DEFAULT_PASS@controller/tacker

[tacker]
# Specify drivers for hosting device
infra_driver = heat,nova,noop

# Specify drivers for mgmt
mgmt_driver = noop,openwrt

# Specify drivers for monitoring
monitor_driver = ping, http_ping

[nfvo_vim]
# Supported VIM drivers, resource orchestration controllers such as OpenStack, kvm
#Default VIM driver is OpenStack
vim_drivers = openstack
#Default VIM placement if vim id is not provided
default_vim = VIM0

[vim_keys]
#openstack = /etc/tacker/vim/fernet_keys

[tacker_nova]
auth_url = http://controller:35357
auth_type = password
auth_plugin = password
project_domain_id = default
user_domain_id = default
region_name = RegionOne
project_name = service
username = nova
password = $DEFAULT_PASS

[tacker_heat]
heat_uri = http://controller:8004/v1
#stack_retries = 60
#stack_retry_wait = 5
EOF
</code></pre>
        Chú ý chỉnh sửa giá trị <code>DEFAULT_PASS</code> cho phù hợp.
        </li>
        <li>Cập nhật cấu hình vào <code>tacker</code> database:
<pre><code>
/usr/local/bin/tacker-db-manage --config-file /usr/local/etc/tacker/tacker.conf upgrade head
</code></pre>
        </li>
    </ol>

    <h3>Cài đặt Tacker client</h3>
    <div>
<pre><code>
cd ~/
git clone -b stable/mitaka https://github.com/openstack/python-tackerclient
cd python-tackerclient
python setup.py install
</code></pre>
    </div>

    <h3>Cài đặt Tacker horizon</h3>
    <ol>
    <li>Clone tacker horizon repo và cài đặt:
<pre><code>
cd ~/
git clone -b stable/mitaka https://github.com/openstack/tacker-horizon
cd tacker-horizon
python setup.py install
</code></pre>
    </li>
    <li>Kích hoạt tacker horizon trên dashboard:
<pre><code>
cp openstack_dashboard_extensions/* /usr/share/openstack-dashboard/openstack_dashboard/enabled/
</code></pre>
    </li>
    <li>Restart Apache server
<pre><code>
sudo service apache2 restart
</code></pre>
    </li>
    </ol>

     <h3>Kích hoạt tacker-server khi reboot</h3>
     <ol>
         <li>Tạo file cấu hình kích hoạt tacker-server khi reboot:
<pre><code>
cd ~/
cfg=/etc/init/tacker-server.conf

cat << EOF > $cfg
# vim:set ft=upstart ts=2 et:
description "Tacker API Server"

start on runlevel [2345]
stop on runlevel [!2345]

respawn

chdir /var/run

pre-start script
  mkdir -p /var/run/tacker
  chown root:root /var/run/tacker
end script

script
  [ -x "/usr/local/bin/tacker-server" ] || exit 0
  [ -r /etc/default/openstack ] && . /etc/default/openstack
  [ "x$USE_SYSLOG" = "xyes" ] && DAEMON_ARGS="$DAEMON_ARGS --use-syslog"
  [ "x$USE_LOGFILE" != "xno" ] && DAEMON_ARGS="$DAEMON_ARGS --log-file=/var/log/tacker/tacker.log"
  exec start-stop-daemon --start --chuid root --exec /usr/local/bin/tacker-server -- \
  --config-file=/usr/local/etc/tacker/tacker.conf \${DAEMON_ARGS}
end script
EOF
</code></pre>
         </li>
         <li>Áp dụng cấu hình, kích hoạt tacker-server khi khởi động:
<pre><code>
ln -sf /lib/init/upstart-job /etc/init.d/tacker-server
update-rc.d -f tacker-server remove
update-rc.d tacker-server defaults
</code></pre>
         </li>
         <li>Khởi động lại các dịch vụ neutron và tacker-server
<pre><code>
# neutron services
service neutron-server restart
service neutron-l3-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart
service neutron-openvswitch-agent restart

#tacker services
service tacker-server restart
</code></pre>
         </li>
     </ol>
</div>

<h2><a name="check">3. Kiểm tra kết quả cài đặt</a></h2>
<div>
    <h3>Tạo các network</h3>
    <div>
        Chú ý bài lab này sử dụng dải mạng ngoài là: <code>172.16.69.0/24</code> và <code>physical_network</code> alias là <code>provider</code>. Chú ý chỉnh sửa cho phù hợp với cấu hình <code>ml2_conf.ini</code>.
<pre><code>
# external network
source ~/admin-openrc admin

neutron net-create ext-net --router:external --provider:physical_network provider --provider:network_type flat
neutron subnet-create ext-net 172.16.69.0/24 --name ext-subnet --allocation-pool start=172.16.69.143,end=172.16.69.149 --disable-dhcp --gateway 172.16.69.1 --dns-nameserver 8.8.8.8

# project networks
source ~/admin-openrc nfv

neutron net-create net0
neutron subnet-create --name net0_sub \
--gateway 10.10.11.1 \
--dns-nameserver 8.8.8.8 \
net0 10.10.11.0/24

neutron net-create net1
neutron subnet-create --name net1_sub \
--gateway 10.10.12.1 \
--dns-nameserver 8.8.8.8 \
net1 10.10.12.0/24
</code></pre>
    </div>

    <h3>Đăng ký default VIM - Virtualized Infrastructure Manager</h3>
    <div>
<pre><code>
# parameters
MGMT_IP=10.10.10.193
DEFAULT_PASS=Welcome123

# create VIM config file
cat << EOF > config.yaml
auth_url: http://$MGMT_IP:5000
username: nfv_user
password: "$DEFAULT_PASS"
project_name: nfv
project_domain_name: default
user_domain_name: default
EOF

# register new VIM
source ~/admin-openrc nfv
tacker vim-register --config-file config.yaml --name VIM0 \
--description "Default VIM"
</code></pre>
    </div>

    <h3>Tạo sample VNFD - Virtualized Network Function Descriptor</h3>
    <div>
        <ol>
            <li>Tạo VNFD
<pre><code>
source ~/admin-openrc nfv

cat << EOF > sample-vnfd.yaml
template_name: sample-vnfd
description: demo-example

service_properties:
  Id: sample-vnfd
  vendor: tacker
  version: 1

vdus:
  vdu1:
    id: vdu1
    vm_image: cirros
    instance_type: m1.tiny

    network_interfaces:
      management:
        network: net0
        management: true

    placement_policy:
      availability_zone: nova

    auto-scaling: noop

    config:
      param0: key0
      param1: key1
EOF
tacker vnfd-create --name sample-vnfd --vnfd-file sample-vnfd.yaml
</code></pre>
        Chú ý chỉnh các tham số cho phù hợp.
            </li>
            <li>Deploy VNF
<pre><code>
tacker vnf-create --name simple-vnf --vnfd-id <vnfd-id>
</code></pre>
            Chú ý tham số <code><vnfd-id></code> thu được sau khi tạo VNFD ở trên.
            </li>
            Chờ khoảng 1 phút để VNF tạo xong, kiểm tra lại:
<pre><code>
$ tacker vnf-list
+--------------------------------------+------------+--------------+------------------------+--------+--------------------------------------+------------------------+
| id                                   | name       | description  | mgmt_url               | status | vim_id                               | placement_attr         |
+--------------------------------------+------------+--------------+------------------------+--------+--------------------------------------+------------------------+
| a9f6bc08-bc2e-467a-8671-cf5b80b9a3df | simple-vnf | demo-example | {"vdu1": "10.10.11.5"} | ACTIVE | 2d734ad9-89e6-4fe4-92b8-925cb65fd08e | {u'vim_name': u'VIM0'} |
+--------------------------------------+------------+--------------+------------------------+--------+--------------------------------------+------------------------+
</code></pre>
        </ol>
    </div>
</div>

<h2><a name="ref">4. Tham khảo</a></h2>
[1] - <a href="http://docs.openstack.org/developer/tacker/install/manual_installation.html">http://docs.openstack.org/developer/tacker/install/manual_installation.html</a>
<br>
[2] - <a href="http://www.opnfv-tech.com/2016/07/05/vnfd-template-para/">http://www.opnfv-tech.com/2016/07/05/vnfd-template-para/</a>

