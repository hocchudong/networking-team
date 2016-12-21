#!/bin/bash
ip=192.168.116.129
api_url=https://hooks.slack.com/services/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
user=root #user mysql
password=Welcome123 #password mysql
host=127.0.0.1      #host mysql
port=3305           #port mysql

##############
#INSTALL prometheus + grafana + alert to slack
echo "INSTALL Prometheus"
cd /opt
wget https://github.com/prometheus/prometheus/releases/download/v1.4.1/prometheus-1.4.1.linux-amd64.tar.gz
tar -xvf prometheus-1.4.1.linux-amd64.tar.gz
cd /opt/prometheus-1.4.1.linux-amd64
cp prometheus.yml prometheus.yml.backup
cat /dev/null > prometheus.yml
cat <<EOF>> prometheus.yml
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
EOF
#########################
echo "INSTALL MYSQL exporter"
cd /opt
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.9.0/mysqld_exporter-0.9.0.linux-amd64.tar.gz
tar -xvf mysqld_exporter-0.9.0.linux-amd64.tar.gz
cd mysqld_exporter-0.9.0.linux-amd64.tar.gz
cat <<EOF>> /root/.my.cnf
[client]
user=$user
password=$password
host=$host
port=$port
EOF
/opt/mysqld_exporter-0.9.0.linux-amd64/mysqld_exporter -collect.binlog_size=true -collect.info_schema.processlist=true &
echo " Truy cap http://$ip:9104/metrics de kiem tra"
##############################3
echo "Cau hinh alert"
cd /opt/prometheus-1.4.1.linux-amd64
cat <<EOF>> alert.rules
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
EOF
#################
echo ""
cd /opt/
wget https://github.com/prometheus/alertmanager/releases/download/v0.5.1/alertmanager-0.5.1.linux-amd64.tar.gz
tar -xvf alertmanager-0.5.1.linux-amd64.tar.gz
cd /opt/alertmanager-0.5.1.linux-amd64
cat <<EOF>> alertmanager.yml
route:
  receiver: 'slack'
receivers:
  - name: 'slack'
    slack_configs:
      - send_resolved: true
        username: 'monitor'
        channel: '#general'
        api_url: '$api_url'
EOF
./alertmanager -config.file=alertmanager.yml &
echo "Kiểm tra: http://$ip:9093/"
cd /opt/prometheus-1.4.1.linux-amd64
./prometheus -config.file=prometheus.yml -alertmanager.url=http://$ip:9093 &
######
echo "INSTALL grafana"
cd /opt/
wget https://grafanarel.s3.amazonaws.com/builds/grafana_4.0.2-1481203731_amd64.deb
apt-get install -y adduser libfontconfig
dpkg -i grafana_4.0.2-1481203731_amd64.deb
grafana-cli plugins install percona-percona-app
service grafana-server restart
update-rc.d grafana-server defaults 95 10
echo "http://$ip:3000"