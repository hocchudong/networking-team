#Prometheus
#Mục lục
**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*

- [1. Prometheus là gì?](#promethes)
- [2. Bối cảnh giải pháp ra đời:](#lichsu)
- [3. So sánh với các giải pháp monitoring khác: zabbix.](#sosanh)
- [4. Thành phần - Kiến trúc:](#kientruc)
- [5. Cài đặt](#caidat)
- [6. Demo:](#demo)
- [7. Viết exporters](#exporter)
- [8. Các thông tin chi tiết.](#chitiet)
	- [8.1 Metrics types](#metrics_type)
	- [8.2 Querying:](#querying)
	- [8.3 Configuration:](#conf)
	- [8.4 Alerting:](#alert)
	- [8.5 Federation:](#federate)
	- [8.6 Pushgateway](#pushgateway)

<a name="promethes"></a>
#1. Prometheus là gì?
Prometheus là giải pháp mã nguồn mở dùng để theo dõi (monitoring) và cảnh báo (alert) cho hệ thống, dịch vụ như:
- Linux OS
- MySQL
- Ceph
- Memcached
- Haproxy

Các tính năng của Prometheus:
- Lưu trữ dữ liệu bằng time series: tên metrics và giá trị theo từng thời điểm.
- Câu lệnh truy vấn thông tin linh hoạt.
- Lấy metrics thông qua thao tác **pull** ở giao thức HTTP.
- **push metrics** thông qua cổng trung gian.
- Có hỗ trợ discovery: tự động tìm ra targets để monitor.

<a name="lichsu"></a>
#2. Bối cảnh giải pháp ra đời:
- Năm 2012, Prometheus được xây dựng bởi SoundCloud nhằm tạo ra hế thống monitoring cho soundcloud.com - một trang chia sẽ các bản thi âm trực tuyến.
- Kể từ đấy, đã có nhiều công ty và tổ chức cùng nhiều developer trên thế giới tham gia vào dự án này.
- Năm 2016, prometheus tham gia vào dự án **Cloud Native Computing Foundation**: là tổ chức phi lợi nhuận cho sự phát triển công nghệ, dịch vụ cho cloud.

<a name="sosanh"></a>
#3. So sánh với các giải pháp monitoring khác: zabbix.

Zabbix tích hợp sẵn các thành phần như biểu đồ, cảnh báo vào phần core của nó.

Prometheus muốn sử dụng các thành phần như biểu đồ, cảnh báo thì phải cài đặt thêm các công cụ khác. (Grafana, alertmanager).

Zabbix sử dụng cơ sở dữ liệu quan hệ để lưu trữ.

Prometheus sử dụng time-series database để lưu trữ. Các bản ghi đi kèm với timestamp. Được đánh giá là có hiệu năng cao hơn so với cơ sở dữ liệu quan hệ.

Zabbix sử dụng giao thức tcp để trao đổi giữa agent-server.

Prometheus sử dụng giao thức http. Các thông tin metrics được hiển thị theo chuẩn (prometheus có thể đọc và xử lý).


Prometheus sử dụng các "exports" (ví dụ: node export, mysql export) để thu thập các metrics và hiển thị trên giao thức http. Người dùng có thể tự viết các export dựa trên các thư viện mà prometheus hỗ trợ (Có viết bằng go, python, java, php,...)

<a name="kientruc"></a>
#4. Thành phần - Kiến trúc:

![](https://prometheus.io/assets/architecture.svg)

Các thành phần có trong Prometheus:
- Prometheus server có nhiệm vụ: *scrapes* và lưu trữ dữ liệu.
- Client libraries: Prometheus cung cấp các thư viện để áp dụng vào ứng dụng.
- Push gateway phù hợp với các công việc short-lived. Các short-lived là những công việc không tồn tại lâu để mà prometheus có thể **scraped** metrics. Vì vậy, các job này sẽ đẩy **push** các metrics này đến Pushgateway. Sau đó Prometheus sẽ **scrapes** Pushgateway để có được metrics.
- Giao diện web GUI.
- Các exporters có nhiệm vụ thu thập metrics.
- Hệ thống cảnh báo alertmanager.
- Giao diện dòng lệnh command-line querying.


Cách hoạt động:
- Các jobs được phân chia thành short-lived và long-lived jobs/Exporter.

Short-lived là những job sẽ tồn tại trong thời gian ngắn và prometheus-server sẽ không kịp scrapes metrics của các jobs này. Do đó, những short-lived jobs sẽ push (đẩy) các metrics đến một nơi gọi là Pushgateway. Pushgateway sẽ là nơi sẽ phơi bày metrics ra và prometheus-server sẽ lấy được metrics của short-lived thông qua Pushgateway.

Long-lived jobs/Exporter: Là những job sẽ tồn tại lâu dài. Các Exporter sẽ được chạy như dưới dạng 1 service. Exporter sẽ có nhiệm vụ thu thập metrics và phơi bày metrics đấy ra. Prometheus-server sẽ scrapes được metrics thông qua hành động pull (kéo).

- Prometheus-server **scrapes** metrics từ các jobs. Sau đó, nó sẽ lưu trữ các metrics này vào Database. (Lưu trữ trong thư mục data). Prometheus sử dụng kiểu time-series database (arrays of numbers indexed by time). Dựa vào các rules mà ta quy định, (ví dụ như khi cpu xử lý hơn 80%) thì prometheus-server sẽ push (đẩy) cảnh báo đến thành phần Alertmanager.

- PromDash, Grafana,.. dùng câu lệnh querying (PromQL - Prometheus Query Language) để lấy được thông tin metrics lưu trữ ở Prometheus-server và trình diễn.

- Alertmanager sẽ được cấu hình các thông tin cần thiết để có thể gửi cảnh bảo đến email, slack,.... Sau khi prometheus-server push alerts đến alertmanager, alertmanager sẽ gửi cảnh báo đến người dùng.

<a name="caidat"></a>
#5. Cài đặt
##5.1 Prometheus server:
Là nơi sẽ "scrapes" và lưu trữ metrics.

- Cài đặt từ file đã được biên dịch: https://prometheus.io/download/
- Biên dịch từ source code: https://github.com/prometheus/prometheus.
Khi biên dịch từ source code, bạn phải cài đặt sẵn Go environment để cs thể hoạt động được.
- Cài đặt từ docker: https://hub.docker.com/u/prom/

##5.2 Exporter:
- Là nơi sẽ thu thập metrics, thường được cài đặt trên máy cần monitor.
- Nơi tổng hợp các Exporter chính chủ và bên thứ 3: https://prometheus.io/docs/instrumenting/exporters/
- Các bạn có thể tự viết Exporter để monitor cho service của mình.

##5.3 Alert manager:
- Là nơi sẽ bắn các cảnh báo đến email, slack....
- https://github.com/prometheus/alertmanager

#6. Demo:
- Tôi có trình bày cách cài đặt "step by step" để monitor hệ thống mysql tại đây: https://github.com/linhlt247/networking-team/blob/master/LinhLT/Prometheus%2Bgrafana/demo/Prometheus_grafana_alert%20to%20slack.md
- Ngoài ra, tôi còn viết script tự động cài đặt theo các bước trên tại đây: https://github.com/linhlt247/networking-team/blob/master/LinhLT/Prometheus%2Bgrafana/demo/install.sh

<a name="exporter"></a>
#7. Viết exporters
Ý tưởng viết exporter: Exporter có nhiệm vụ thu thập các metrics và xuất các metrics ra dựa trên http server. Prometheus-server sẽ pull các mectrics này dựa trên giao thức http. Vì vậy, Exporter gồm 2 thành phần.

- Thành phần 1: Thu thập thông tin cần monitor vào đẩy registry. Có các bước như sau:
  - **Create collectors:**
  ```sh
    ten_collector=kieu_metric("ten_metrics","Tên chi tiết metrics",{Các thông tin bổ sung cho metrics})

    #Ví dụ:
    mysql_seconds_behind_master = Gauge("mysql_slave_seconds_behind_master", "MySQL slave secons behind master",{})
  ```
    Kiểu metrics có 4 kiểu: Counter, Gauge, Histogram, Summary. Với từng use case khác nhau ta sẽ sử dụng một kiểu metrics khác nhau.

    Chi tiết 4 kiểu metric được tôi trình bày trong mục **8.1**

  - **register the metric collectors**

  ```sh
    registry.register(ten_collector)

    #Ví dụ
    registry.register(mysql_seconds_behind_master)
  ```

  - **add metrics**

  ```sh
  ten_collector.set({},values)

  #Ví dụ:
  mysql_seconds_behind_master.set({},slave_file)
  ```
  values là thông số monitor mà mình lấy được. Chú ý là với mỗi loại metrics khác nhau, thì theo tác add metrics lại khác nhau.


  **=>** Các bạn có thể hình dung đơn giản quá trình này như sau: Mỗi thông tin cần monitor là 1 metrics. Để lưu tạm thời giá trị các metrics, các bạn cần phải có 1 thùng chứa. Thì ở đây registry đóng vai trò là thùng chứa. Ứng với mỗi metrics sẽ có 1 thùng chứa riêng nó. Thao tác **set** là đưa giá trị metrics vào thùng chứa. Sau đó ở thành phần 2, sẽ lấy giá trị trong thùng chứa này và hiển thị thông tin.

- Thành phần 2: **Serve data**: Đẩy metrics lên http servers.

```sh
from http.server import HTTPServer
from prometheus.exporter import PrometheusMetricHandler
from prometheus.registry import Registry


# Create the registry
registry = Registry()

# Create the thread that gathers the data while we serve it
thread = threading.Thread(target=gather_data, args=(registry, ))
thread.start()

# We make this to set the registry in the handler
def handler(*args, **kwargs):
    PrometheusMetricHandler(registry, *args, **kwargs)

# Set a server to export (expose to prometheus) the data (in a thread)
server = HTTPServer(('', 8888), handler)
server.serve_forever()
```

Đoạn code trên sẽ tạo ra một http server với địa chỉ ip là máy đang chạy, port là 8888. Nội dung handler chính là nội dung của metrics đã được format theo chuẩn của prometheus. Hàm **MetricHandler** có nhiệm vụ **generating metric output**, dựa trên thông tin có trong registry.


- Tôi sử dụng python để viết 1 exporter thu thập 3 thông số khi thực hiện replication mysql:
    - Slave IO running.
    - Slave SQL running.
    - Seconds behind master.
- Các bạn xem tại đây: https://github.com/linhlt247/networking-team/tree/master/LinhLT/Prometheus%2Bgrafana/mysql%20exporter%20python

<a name="chitiet"></a>
#8. Các thông tin chi tiết.

<a name="metrics_type"></a>
##8.1 Metrics types

Prometheus client libraries cung cấp 4 loại metrics cơ bản:
- Counter: Được sử dụng trong các trường hợp như đếm số request, task complete, errors occurred,..
- Gauge: Thường được sử dụng để đo các giá trị như giá trị nhiệt độ, hoặc giá trị bộ nhớ hiện tại đang sử dụng.
- Histogram:
- Summary:

##8.2 Querying:
Prometheus cung cấp câu lệnh querying cho phép người dùng lựa chọn và tổng hợp dữ liệu chuỗi thời gian thèo thời gian thực.

- Vi dụ:

  - Return all time series with the metric http_requests_total:
```sh
http_requests_total
```
  - Return all time series with the metric http_requests_total and the given job and handler labels:
```sh
http_requests_total{job="apiserver", handler="/api/comments"}
```
  - Return a whole range of time (in this case 5 minutes) for the same vector, making it a range vector:
```sh
http_requests_total{job="apiserver", handler="/api/comments"}[5m]
```

- Ngoài ra, Prometheus hỗ trợ các hàm tính toàn metrics như abs, day_of_month(),day_of_week(),... Các bạn xem chi tiết tại
`https://prometheus.io/docs/querying/functions/``

<a name="conf"></a>
##8.3 Configuration:
```sh
global:
  # How frequently to scrape targets by default.
  [ scrape_interval: <duration> | default = 1m ]

  # How long until a scrape request times out.
  [ scrape_timeout: <duration> | default = 10s ]

  # How frequently to evaluate rules.
  [ evaluation_interval: <duration> | default = 1m ]

  # The labels to add to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    [ <labelname>: <labelvalue> ... ]

# Rule files specifies a list of globs. Rules and alerts are read from
# all matching files.
rule_files:
  [ - <filepath_glob> ... ]

# A list of scrape configurations.
scrape_configs:
  [ - <scrape_config> ... ]

# Alerting specifies settings related to the Alertmanager.
alerting:
  alert_relabel_configs:
    [ - <relabel_config> ... ]
  alertmanagers:
    [- <alertmanager_config> ... ]

# Settings related to the experimental remote write feature.
remote_write:
  [ url: <string> ]
  [ remote_timeout: <duration> | default = 30s ]
  tls_config:
    [ <tls_config> ]
  [ proxy_url: <string> ]
  basic_auth:
    [ username: <string> ]
    [ password: <string> ]
  write_relabel_configs:
    [ - <relabel_config> ... ]
```

- scrape_config

```sh
# The job name assigned to scraped metrics by default.
job_name: <name>

# How frequently to scrape targets from this job.
[ scrape_interval: <duration> | default = <global_config.scrape_interval> ]

# Per-target timeout when scraping this job.
[ scrape_timeout: <duration> | default = <global_config.scrape_timeout> ]

# The HTTP resource path on which to fetch metrics from targets.
[ metrics_path: <path> | default = /metrics ]

# honor_labels controls how Prometheus handles conflicts between labels that are
# already present in scraped data and labels that Prometheus would attach
# server-side ("job" and "instance" labels, manually configured target
# labels, and labels generated by service discovery implementations).
#
# If honor_labels is set to "true", label conflicts are resolved by keeping label
# values from the scraped data and ignoring the conflicting server-side labels.
#
# If honor_labels is set to "false", label conflicts are resolved by renaming
# conflicting labels in the scraped data to "exported_<original-label>" (for
# example "exported_instance", "exported_job") and then attaching server-side
# labels. This is useful for use cases such as federation, where all labels
# specified in the target should be preserved.
#
# Note that any globally configured "external_labels" are unaffected by this
# setting. In communication with external systems, they are always applied only
# when a time series does not have a given label yet and are ignored otherwise.
[ honor_labels: <boolean> | default = false ]

# Configures the protocol scheme used for requests.
[ scheme: <scheme> | default = http ]

# Optional HTTP URL parameters.
params:
  [ <string>: [<string>, ...] ]

# Sets the `Authorization` header on every scrape request with the
# configured username and password.
basic_auth:
  [ username: <string> ]
  [ password: <string> ]

# Sets the `Authorization` header on every scrape request with
# the configured bearer token. It is mutually exclusive with `bearer_token_file`.
[ bearer_token: <string> ]

# Sets the `Authorization` header on every scrape request with the bearer token
# read from the configured file. It is mutually exclusive with `bearer_token`.
[ bearer_token_file: /path/to/bearer/token/file ]

# Configures the scrape request's TLS settings.
tls_config:
  [ <tls_config> ]

# Optional proxy URL.
[ proxy_url: <string> ]

# List of Azure service discovery configurations.
azure_sd_configs:
  [ - <azure_sd_config> ... ]

# List of Consul service discovery configurations.
consul_sd_configs:
  [ - <consul_sd_config> ... ]

# List of DNS service discovery configurations.
dns_sd_configs:
  [ - <dns_sd_config> ... ]

# List of EC2 service discovery configurations.
ec2_sd_configs:
  [ - <ec2_sd_config> ... ]

# List of labeled statically configured targets for this job.
static_configs:
  [ - <static_config> ... ]

# List of target relabel configurations.
relabel_configs:
  [ - <relabel_config> ... ]

# List of metric relabel configurations.
metric_relabel_configs:
  [ - <relabel_config> ... ]
```

<a name="alert"></a>
##8.4 Alerting:
Alerting có 2 thành phần:
- Alerting rules sẽ được cấu hình trên Prometheus-server. Prometheus-server sẽ xử lý các rules này vày push alert đến Alertmanager.
- Alertmanager quản lý cách mà các cảnh báo sẽ được xử lý như thế nào? Có được gửi notifications đến người dùng hay không?

**Grouping:** Phân loại các cảnh báo theo group. Ví dụ ta cấu hình 100 server khi bị failed thì sẽ gửi cảnh báo đến sysadmin. Khi đó, sysadmin sẽ lập tức nhận 100 notification một lúc. Thay vì vậy, ta gom nhóm 100 server này vào 1 group, và sysadmin sẽ chỉ nhận được 1 notification mà thôi.

**Inhibiton:** Sẽ bỏ đi các cảnh báo nhất định nếu một số cảnh báo khác đã được bắn. Ví dự như ta có cụm 1 cụm cluster 100 server bị mất kết nối internet đột ngột. Trên các server này ta có đặt các báo về network, web-server, mysql,... Đo đó, khi mà mất kết nối internet thì tất các cách dịch vụ này đều gửi cảnh báo đến sysadmin. Sử dụng Inhibiton thì khi cảnh báo network được gửi đến sysadmin và các cảnh báo về web-server, mysql sẽ không gửi cần phải gửi đến sysadmin nữa vì sysadmin thừa hiểu là khi mất internet thì các service kia cũng bị failed.

**Silences:** Tắt cảnh báo trong một thời gian nhất định.

###8.4.1 Alerts rules

```sh
ALERT <alert name>
  IF <expression>
  [ FOR <duration> ]
  [ LABELS <label set> ]
  [ ANNOTATIONS <label set> ]
```

###8.4.2 Alert config

```sh
global:
  # ResolveTimeout is the time after which an alert is declared resolved
  # if it has not been updated.
  [ resolve_timeout: <duration> | default = 5m ]

  # The default SMTP From header field.
  [ smtp_from: <tmpl_string> ]
  # The default SMTP smarthost used for sending emails.
  [ smtp_smarthost: <string> ]
  # SMTP authentication information.
  [ smtp_auth_username: <string> ]
  [ smtp_auth_password: <string> ]
  [ smtp_auth_secret: <string> ]
  # The default SMTP TLS requirement.
  [ smtp_require_tls: <bool> | default = true ]

  # The API URL to use for Slack notifications.
  [ slack_api_url: <string> ]

  [ pagerduty_url: <string> | default = "https://events.pagerduty.com/generic/2010-04-15/create_event.json" ]
  [ opsgenie_api_host: <string> | default = "https://api.opsgenie.com/" ]
  [ hipchat_url: <string> | default = "https://api.hipchat.com/" ]
  [ hipchat_auth_token: <string> ]

# Files from which custom notification template definitions are read.
# The last component may use a wildcard matcher, e.g. 'templates/*.tmpl'.
templates:
  [ - <filepath> ... ]

# The root node of the routing tree.
route: <route>

# A list of notification receivers.
receivers:
  - <receiver> ...

# A list of inhibition rules.
inhibit_rules:
  [ - <inhibit_rule> ... ]
```

<a name="federate"></a>
##8.5 Federation:
Federation cho phép một Prometheus-server **scrape** metrics từ các Prometheus-server khác.

Cấu hình trên prometheus server scrape metrics từ các server khác.

```sh
- job_name: 'federate'
  scrape_interval: 15s

  honor_labels: true
  metrics_path: '/federate'

  params:
    'match[]':
      - '{job="prometheus"}'
      - '{__name__=~"job:.*"}'

  static_configs:
    - targets:
      - 'source-prometheus-1:9090'
      - 'source-prometheus-2:9090'
      - 'source-prometheus-3:9090'
```

Lưu ý là phần `{job="prometheus"}` thì tên job phải trùng với job trong các job đã cấu hình ở trên các promethes server khác.

- Sau khi cấu hình xong, các bạn có thể vào địa chỉ: `http://ip:9090/targets` để kiểm tra

<a name="pushgateway"></a>
##8.6 Pushgateway
- Pushgateway được sử dụng trong trường hợp mà Promethes server không thể scrape metrics một cách trực tiếp. Có thể là các job chỉ tồn tại trontg thời gian ngắn mà Promethes server chưa kịp scrape metrics.

- Để giải quyết vấn đề này, thì Pushgateway được ra đời. Pushgateway sẽ đóng vai trò trung gian giữa promethes server và targets
cần monitor.

- Trên targets sẽ được cấu hình để push metrics đến Pushgateway. Rồi từ đó, Prometheus server sẽ scrape (pull) metrics ở Pushgateway.

- All pushes are done via HTTP. The interface is vaguely REST-like.

- Để push metrics lên pushgateway, các bạn có thể sử dụng lệnh curl với các method sau:
  - URL: `http://ip:9091/metrics/job/<JOBNAME>{/<LABEL_NAME>/<LABEL_VALUE>}`
  - PUT method: Push metrics. All metrics with the grouping key specified in the URL are replaced by the metrics pushed with PUT.
  - POST method: POST works exactly like the PUT method but only metrics with the same name as the newly pushed metrics are replaced (among those with the same grouping key).
  - DELETE method: DELETE is used to delete metrics from the push gateway.

###8.6.1 Cấu hình:
- Tải gói Pushgateway:
```sh
wget https://github.com/prometheus/pushgateway/releases/download/v0.3.1/pushgateway-0.3.1.linux-amd64.tar.gz
```
- Giải nén và chạy:
```sh
tar -xvf pushgateway-0.3.1.linux-amd64.tar.gz
cd /pushgateway-0.3.1.linux-amd64
./pushgateway
```
- Ví dụ đơn giản để push metrics:
```sh
echo "some_metric 3.14" | curl --data-binary @- http://ip:9091/metrics/job/some_job
```
- Push metrics với nhiều thông tin hơn:
```sh
cat <<EOF | curl --data-binary @- http://pushgateway.example.org:9091/metrics/job/some_job/instance/some_instance
# TYPE some_metric counter
some_metric{label="val1"} 42
# This one even has a timestamp (but beware, see below).
some_metric{label="val2"} 34 1398355504000
# TYPE another_metric gauge
# HELP another_metric Just an example.
another_metric 2398.283
EOF
```

- Sau khi chạy, ta có thể xem thông tin các metrics đã được push tại địa chỉ: `http://ip:9091/metrics/job/<JOBNAME>{/<LABEL_NAME>/<LABEL_VALUE>}`

- Xóa tất cả metrics cùng job và instance:
```sh
curl -X DELETE ip:9091/metrics/job/some_job/instance/some_instance
```
- Xóa metrics cùng jobs:
```sh
curl -X DELETE http://pushgateway.example.org:9091/metrics/job/some_job
```
