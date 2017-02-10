Prometheus + grafana + alert to slack
#1. Mô hình
- Ta có server với địa chỉ ip: 192.168.116.129, chạy hệ điều hành ubuntu 14.04
- Trên server này cài các gói sau:
  - mysql exporter: có nhiệm vụ lấy các thông tin cần giám sát của mysql và xuất ra metrics mà prometheus có thể hiểu được.
  - prometheus: có nhiệm vụ thu thập các metrics (từ các exporter) và lưu trữ.
  - alertmanager: có nhiệm vụ gửi cảnh báo đến email, slack...
  - grafana: Từ các metrics đã được lưu trữ ở prometheus, grafana có nhiệm vụ lấy và biểu diễn các thông tin đó.
  - plugin grafana: perconal: là plugin grafana, có chứa sẵn các biểu đồ dành cho mysql, mariadb.

#2. Prometheus
- Tải prometheus:  
```sh
cd /opt
wget https://github.com/prometheus/prometheus/releases/download/v1.4.1/prometheus-1.4.1.linux-amd64.tar.gz
tar -xvf prometheus-1.4.1.linux-amd64.tar.gz
```
- Cấu hình prometheus:
```sh
cd /opt/prometheus-1.4.1.linux-amd64
vi prometheus.yml
```
- Nội dung file `prometheus.yml`:
```sh
# my global config
global:
  scrape_interval: 5s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 5s # Evaluate rules every 15 seconds. The default is every 1 minute.

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  - "alert.rules"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  - job_name: prometheus
    static_configs:
    - targets: ['localhost:9090']
      labels:
        instance: prometheus
        alias: prometheus
  - job_name: mysql
    static_configs:
    - targets: ['localhost:9104']
      labels:
        instance: mysql
        alias: hanoi-slave
```
- ở phần cấu hình trên, ta chú ý phần targets: ['localhost:9104']: chính là địa chỉ mà mysql exporter xuất ra các metrics và prometheus sẽ dựa vào địa chỉ này để lấy các metrics.

#3 CONFIG MYSQL EXPORTER
- Tải mysql exporter
```sh
cd /opt
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.9.0/mysqld_exporter-0.9.0.linux-amd64.tar.gz
tar -xvf mysqld_exporter-0.9.0.linux-amd64.tar.gz
cd mysqld_exporter-0.9.0.linux-amd64
```
- Cấu hình thông tin mysql cần monitor:
```sh
vi /root/.my.cnf
```
```sh
[client]
user=root
password=Welcome123
host=127.0.0.1
port=3305
```
- Chạy exporter
```sh
/opt/mysqld_exporter-0.9.0.linux-amd64/mysqld_exporter -collect.binlog_size=true -collect.info_schema.processlist=true
```
- Kết quả: Truy cập http://192.168.116.129:9104/metrics ta được:

#4 ALERT to SLACK
##4.1 CONFIG SLACK
Truy cập `https://api.slack.com/custom-integrations` và enable webhook

##4.2 Cấu hình prometheus:
```sh
cd /opt/prometheus-1.4.1.linux-amd64
vi alert.rules
```
```sh
ALERT MySQLSlaveLag
  IF mysql_slave_status_seconds_behind_master > 300
  FOR 1m
  LABELS { severity = "warning" }
  ANNOTATIONS { summary = "Slave lag is too high.", severity="warning" }

ALERT MySQLReplicationSQLThreadStatus
  IF mysql_slave_status_slave_sql_running==0
  FOR 1m
  LABELS { severity = "warning" }
  ANNOTATIONS { summary = "SQL thread stop", severity="warning"}

ALERT MySQLReplicationIOThreadStatus
  IF mysql_slave_status_slave_io_running==0
  FOR 1m
  LABELS { severity = "warning" }
  ANNOTATIONS { summary = "IO thread stop", severity="warning"}

ALERT MySQLstatus
  IF mysql_up==0
  FOR 30s
  LABELS { severity = "warning" }
  ANNOTATIONS { summary = "Mysql Process Down" }
```
- Cấu hình các rules. Alertmanager sẽ dựa vào các rules này để gửi cảnh báo.

##4.3 Config alert to slack
- Tải alert manager
```sh
cd /opt/
wget https://github.com/prometheus/alertmanager/releases/download/v0.5.1/alertmanager-0.5.1.linux-amd64.tar.gz
tar -xvf alertmanager-0.5.1.linux-amd64.tar.gz
cd /opt/alertmanager-0.5.1.linux-amd64
vi alertmanager.yml
```
- Cấu hình file alertmanager.yml
```sh
# alertmanager.yml
route:
  receiver: 'slack'
receivers:
  - name: 'slack'
    slack_configs:
      - send_resolved: true
        username: 'monitor'
        channel: '#general'
        api_url: 'https://hooks.slack.com/services/xxxxxx/xxxxxxx'
```
Trong đó: api_url: là địa chỉ webhook của slack.

- Chạy:
```sh
./alertmanager -config.file=alertmanager.yml
```
- Kiểm tra: `http://192.168.116.129:9093/`

- Cuối cùng chạy:
```sh
cd /opt/prometheus-1.4.1.linux-amd64
./prometheus -config.file=prometheus.yml -alertmanager.url=http://192.168.116.129:9093
```

- Để gửi mail đến gmail:
```sh
receivers:
- name: email-me
  email_configs:
  - to: $GMAIL_ACCOUNT
    from: $GMAIL_ACCOUNT
    smarthost: smtp.gmail.com:587
    auth_username: "$GMAIL_ACCOUNT"
    auth_identity: "$GMAIL_ACCOUNT"
    auth_password: "$GMAIL_AUTH_TOKEN"
```

#5. Install grafana
- Cài đặt
```sh
cd /opt/
wget https://grafanarel.s3.amazonaws.com/builds/grafana_4.0.2-1481203731_amd64.deb
apt-get install -y adduser libfontconfig
dpkg -i grafana_4.0.2-1481203731_amd64.deb
```
- Cài đặt plugin percona
```sh
grafana-cli plugins install percona-percona-app
service grafana-server restart
```
- Truy cập:
```sh
http://192.168.116.129:3000
```
Đăng nhập với tài khoản `admin/admin`. Thực hiện các bước sau:
- enable plugin percona

![](http://image.prntscr.com/image/a1d67911a9274ce3b708e6d7edeb8da6.png)

- add datasource prometheu

![](http://image.prntscr.com/image/4d7a1e5565874b9a8ebb0c0313573e9e.png)

#6. Kết quả:
![](http://image.prntscr.com/image/187ed17f74634219b1c4510951a8ee1e.png)

![](http://image.prntscr.com/image/416e4a6b546b434b9c244fd58eb7e311.png)
