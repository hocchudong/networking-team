Prometheus
#1. Prometheus là gì?
Prometheus là giải pháp mã nguồn mở dùng để theo dõi (monitoring) và cảnh báo (alert) cho hệ thống, dịch vụ như:
- Linux OS
- MySQL
- Ceph
- Memcached
- Haproxy

#2. Bối cảnh giải pháp ra đời:
- Prometheus được xây dựng bởi SoundCloud nhằm tạo ra hế thống monitoring cho soundcloud.com - một trang chia sẽ các bản thi âm trực tuyến.
- Kể từ năm 2012, đã có nhiều công ty và tổ chức cùng nhiều developer trên thế giới tham gia vào dự án này.
- Năm 2016, prometheus tham gia vào dự án **Cloud Native Computing Foundation**: là tổ chức phi lợi nhuận cho sự phát triển công nghệ, dịch vụ cho cloud.

#3. So sánh với các giải pháp monitoring khác: zabbix.

Zabbix tích hợp sẵn các thành phần như biểu đồ, cảnh báo vào phần core của nó.

Prometheus muốn sử dụng các thành phần như biểu đồ, cảnh báo thì phải cài đặt thêm các công cụ khác. (Grafana, alertmanager).

Zabbix sử dụng cơ sở dữ liệu quan hệ để lưu trữ.

Prometheus sử dụng time-series database để lưu trữ. Các bản ghi đi kèm với timestamp. Được đánh giá là có hiệu năng cao hơn so với cơ sở dữ liệu quan hệ.

Zabbix sử dụng giao thức tcp để trao đổi giữa agent-server.

Prometheus sử dụng giao thức http. Các thông tin metrics được hiển thị theo chuẩn (prometheus có thể đọc và xử lý).


Prometheus sử dụng các "exports" (ví dụ: node export, mysql export) để thu thập các metrics và hiển thị trên giao thức http. Người dùng có thể tự viết các export dựa trên các thư viện mà prometheus hỗ trợ (Có viết bằng go, python, java, php,...)

#4. Kiến trúc - Thành phần: 

![](https://prometheus.io/assets/architecture.svg)


- Prometheus server có nhiệm vụ: *scrapes* và lưu trữ dữ liệu.
- Push gateway phù hợp với các công việc short-lived.
- Giao diện web GUI. 
- Các exporters có nhiệm vụ thu thập metrics.
- Hệ thống cảnh bá alertmanager.

#5. Cài đặt
#5.1 Prometheus server: 
Là nơi sẽ "scrapes" và lưu trữ metrics.

- Cài đặt từ file đã được biên dịch: https://prometheus.io/download/
- Biên dịch từ source code: https://github.com/prometheus/prometheus.
Khi biên dịch từ source code, bạn phải cài đặt sẵn Go environment để cs thể hoạt động được.
- Cài đặt từ docker: https://hub.docker.com/u/prom/

#5.2 Exporter:
- Là nơi sẽ thu thập metrics, thường được cài đặt trên máy cần monitor.
- Nơi tổng hợp các Exporter chính chủ và bên thứ 3: https://prometheus.io/docs/instrumenting/exporters/
- Các bạn có thể tự viết Exporter để monitor cho service của mình.

#5.3 Alert manager:
- Là nơi sẽ bắn các cảnh báo đến email, slack....
- https://github.com/prometheus/alertmanager

#6. Demo:
- Tôi có trình bày cách cài đặt "step by step" để monitor hệ thống mysql tại đây: 
- Ngoài ra, tôi còn viết script tự động cài đặt theo các bước trên tại đây: 

#7. Viết exporters
- Tôi sử dụng python để viết 1 exporter thu thập 3 thông số khi thực hiện replication mysql: 
    - Slave IO running.
    - Slave SQL running.
    - Seconds behind master.
- Các bạn xem tại đây: 





