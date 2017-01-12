#MySQL exporter for prometheus
#1. Prerequisites
- Install python3
```sh
apt-get install python3
```

- Install pip3
```sh
apt-get install python3-pip
```

- Install prometheus client:
```sh
pip3 install prometheus_client
```

- Install prometheus
```sh
pip3 install prometheus
```

- Install mysqlclient
```sh
apt-get install python3-dev libmysqlclient-dev
pip3 install mysqlclient
```

#2. Run
```sh
wget 
python3 mysql.py
```
Metrics will export where: http://ipaddress_server:4444/metrics

![](http://image.prntscr.com/image/ceed89b1730441b1bf5d6ab5e53d3490.png)

#3. Config prometheus


#4. Reference
https://prometheus.io/docs/introduction/overview/

https://github.com/prometheus/client_python

https://github.com/PyMySQL/mysqlclient-python

https://mysqlclient.readthedocs.io/en/latest/index.html

https://etl.svbtle.com/mysql-replication-slave-monitoring-script-for-zenoss

https://kb.paessler.com/en/topic/39913-how-can-i-monitor-mysql-replication-on-a-linux-machine

