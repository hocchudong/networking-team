#NOTE

1.Giải pháp này là gì ?
2.Bối cảnh lịch sử ra đời hay là vai trò, ý nghĩa của giải pháp?
3.Có nhiều giải pháp tương tự rồi sao tôi lựa chọn giải pháp này (So sánh ưu nhược điểm, đánh giá)?
4.Các thành phần hệ thống, kiến trúc hay mối tương tác giữa các thành phần?
5.Cài đặt có những cách nào (cài từ source, repo hay chạy trên docker,v..v). Các thành phần nào bắt buộc phải cài trên 1 máy, thành phần nào có thể tách rời?
6.Các thành phần, hệ thống phục thuộc(nếu có)?
7.Cấu hình, giá trị mặc định là bao nhiêu?
8.Hệ thống có hỗ trợ HA, thành phần nào hỗ trợ thành phần nào không?
9.Hệ thống có thể mở rộng không, mở rộng bằng cách nào?
10.Tài nguyên (RAM, CPU) tiêu thụ là bao nhiêu?
11. Nếu là mà nguồn mở thì viết thêm tính năng vào giải pháp hay định nghĩa các API như thế nào?
12. Triển khai thực tế cần lưu ý gì? 

#1. Prometheus
Giải pháp mã nguồn mở dùng để monitoring, cảnh báo hệ thống.
#2. 
- Được xây dựng bởi SoundCloud (http://soundcloud.com/), từ 2012.
- Được SoundCloud xây dựng để monitoring hệ thống của chính họ.
#3. So sánh với zabbix
Zabbix tích hợp sẵn các thành phần như biểu đồ, cảnh báo vào phần core của nó.
Prometheus muốn sử dụng các thành phần như biểu đồ, cảnh báo thì phải cài đặt thêm các công cụ khác. (Grafana, alertmanager).

Zabbix sử dụng cơ sở dữ liệu quan hệ để lưu trữ.
Prometheus sử dụng time-series database để lưu trữ. Các bản ghi đi kèm với timestamp. Được đánh giá là có hiệu năng cao hơn so với cơ sở dữ liệu quan hệ.

Zabbix sử dụng giao thức tcp để trao đổi giữa agent-server.
Prometheus sử dụng giao thức http. Các thông tin metrics được hiển thị theo chuẩn (prometheus có thể đọc và xử lý).

Prometheus sử dụng các "exports" (ví dụ: node export, mysql export) để thu thập các metrics và hiển thị trên giao thức http.

#4. 
![](https://prometheus.io/assets/architecture.svg)

#5. 

#7. 

#8. 

#9.

#10.

#11

#12
