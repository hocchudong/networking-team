#Prometheus
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

#2. Bối cảnh giải pháp ra đời:
- Năm 2012, Prometheus được xây dựng bởi SoundCloud nhằm tạo ra hế thống monitoring cho soundcloud.com - một trang chia sẽ các bản thi âm trực tuyến.
- Kể từ đấy, đã có nhiều công ty và tổ chức cùng nhiều developer trên thế giới tham gia vào dự án này.
- Năm 2016, prometheus tham gia vào dự án **Cloud Native Computing Foundation**: là tổ chức phi lợi nhuận cho sự phát triển công nghệ, dịch vụ cho cloud.

#3. So sánh với các giải pháp monitoring khác: zabbix.

Zabbix tích hợp sẵn các thành phần như biểu đồ, cảnh báo vào phần core của nó.

Prometheus muốn sử dụng các thành phần như biểu đồ, cảnh báo thì phải cài đặt thêm các công cụ khác. (Grafana, alertmanager).

Zabbix sử dụng cơ sở dữ liệu quan hệ để lưu trữ.

Prometheus sử dụng time-series database để lưu trữ. Các bản ghi đi kèm với timestamp. Được đánh giá là có hiệu năng cao hơn so với cơ sở dữ liệu quan hệ.

Zabbix sử dụng giao thức tcp để trao đổi giữa agent-server.

Prometheus sử dụng giao thức http. Các thông tin metrics được hiển thị theo chuẩn (prometheus có thể đọc và xử lý).


Prometheus sử dụng các "exports" (ví dụ: node export, mysql export) để thu thập các metrics và hiển thị trên giao thức http. Người dùng có thể tự viết các export dựa trên các thư viện mà prometheus hỗ trợ (Có viết bằng go, python, java, php,...)

#4. Thành phần - Kiến trúc: 

![](https://prometheus.io/assets/architecture.svg)

Các thành phần có trong Prometheus: 
- Prometheus server có nhiệm vụ: *scrapes* và lưu trữ dữ liệu.
- Client libraries: Prometheus cung cấp các thư viện để áp dụng vào ứng dụng.
- Push gateway phù hợp với các công việc short-lived. Các short-lived là những công việc không tồn tại lâu để mà prometheus có thể ***scraped** metrics. Vì vậy, các job này sẽ đẩy **push** các metrics này đến Pushgateway. Sau đó Prometheus sẽ **scrapes** Pushgateway để có được metrics.
- Giao diện web GUI. 
- Các exporters có nhiệm vụ thu thập metrics.
- Hệ thống cảnh báo alertmanager.
- Giao diện dòng lệnh command-line querying.


Cách hoạt động: 
- Các jobs được phân chia thành short-lived và long-lived jobs/Exporter. 

Short-lived là những job sẽ tồn tại trong thời gian ngắn và prometheus-server sẽ không kịp scrapes metrics của các jobs này. Do đó, những short-lived jobs sẽ push (đẩy) các metrics đến một nơi gọi là Pushgateway. Pushgateway sẽ là nơi sẽ phơi bày metrics ra và prometheus-server sẽ lấy được metrics của short-lived thông qua Pushgateway.

Long-lived jobs/Exporter: Là những job sẽ tồn tại lâu dài. Các Exporter sẽ được chạy như dưới dạng 1 service. Exporter sẽ có nhiệm vụ thu thập metrics và phơi bày metrics đấy ra. Prometheus-server sẽ scrapes được metrics thông qua hành động pull (kéo).

- Prometheus-server **scrapes** metrics từ các jobs. Sau đó, nó sẽ lưu trữ các metrics này vào Database. Prometheus sử dụng kiểu time-series database (arrays of numbers indexed by time). Dựa vào các rules mà ta quy định, (ví dụ như khi cpu xử lý hơn 80%) thì prometheus-server sẽ push (đẩy) cảnh báo đến thành phần Alertmanager.

- PromDash, Grafana,.. dùng câu lệnh querying để lấy được thông tin metrics lưu trữ ở Prometheus-server và trình diễn.

- Alertmanager sẽ được cấu hình các thông tin cần thiết để có thể gửi cảnh bảo đến email, slack,.... Sau khi prometheus-server push alerts đến alertmanager, alertmanager sẽ gửi cảnh báo đến người dùng.

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

#7. Viết exporters
- Tôi sử dụng python để viết 1 exporter thu thập 3 thông số khi thực hiện replication mysql: 
    - Slave IO running.
    - Slave SQL running.
    - Seconds behind master.
- Các bạn xem tại đây: https://github.com/linhlt247/networking-team/tree/master/LinhLT/Prometheus%2Bgrafana/mysql%20exporter%20python

#8. Các thông tin chi tiết.
##8.1 Data model:
##8.2 Storage:
##8.3 Metrics types:
##8.4 Querying:
##8.5 Configuration:
##8.5 Federation:
##8.6 Alerting:
#9. Các thuật ngữ.
