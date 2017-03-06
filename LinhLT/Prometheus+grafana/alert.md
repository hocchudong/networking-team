#Alert và một vài vấn đề nâng cao.
Trước khi đọc bài này, các bạn hãy đọc phần 6 - alert trong file `README.md` để có cái nhìn tổng quát 
về tính năng cảnh báo của prometheus.
#Mục lục
- [1. Định tuyến các đường đi của thông báo](#dinhtuyen)
- [2. Các vấn đề trong cảnh báo](#vande)
- [3. Tính năng group trong cảnh báo](#group)

<a name="dinhtuyen"></a>
#1. Định tuyến các đường đi của thông báo:
Đầu tiên, ta hãy xem qua file cấu hình cảnh báo:
```sh
global:
# The smarthost and SMTP sender used for mail notifications.
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: 'sender@gmail.com'
  smtp_auth_username: 'sender@gmail.com'
  smtp_auth_password: 'abcxyz@123'
#route default
route:
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 3h 
  receiver: default
#route-child
  routes:
  - match:
      severity: warning
    receiver: gmail
  - match:
      severity: critical
    receiver: slack
  - match_re:
      service: ^(foo1|foo2|baz)$
    receiver: slack

# Inhibition rules allow to mute a set of alerts given that another alert is
# firing.
# We use this to mute any warning-level notifications if the same alert is 
# already critical.
inhibit_rules:
- source_match:
    severity: 'critical'
  target_match:
    severity: 'warning'
  # Apply inhibition if the alertname is the same.
  equal: ['alertname']

#receiver default
receivers:
- name: 'default'
  email_configs:
  - to: 'sysadmin1@gmail.com, sysadmin2@gmail.com'
  slack_configs:
  - send_resolved: true
    username: 'monitor'
    channel: '#default'
    api_url: 'https://hooks.slack.com/services/xxxxxxxxxxx/xxxxxxxxxxx/xxxxxxxxxx'
#receiver gmail
- name: 'gmail'
  email_configs:
  - to: 'man1@gmail.com'
#receiver man2
- name: 'slack'
  slack_configs:
    - send_resolved: true
      username: 'monitor'
      channel: '#general'
      api_url: 'https://hooks.slack.com/services/xxxxxxxxxxx/xxxxxxxxxxx/xxxxxxxxxx'
```

- **Phần global:** là nơi khai báo giá trị các biến toàn cục được sử dụng trong file cấu hình này.
```sh
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: 'sender@gmail.com'
  smtp_auth_username: 'sender@gmail.com'
  smtp_auth_password: 'abcxyz@123'
```
Cụ thể là ở đây tôi cấu hình những thông tin cần thiết để có thể gửi cảnh báo đến 1 hộp thư gmail.

- **Phần route:** Là nơi cấu hình các thông tin đường đi mặc định. Tức là mặc định các cảnh báo sẽ được gưỉ theo đường này
nếu không cấu hình các đường đi con khác.
```sh
#route default
route:
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 30s
  repeat_interval: 2m 
  receiver: default
```
    - group_by: Dòng này có ý nghĩa prometheus sẽ gom những thông báo có cùng `alertname` vào 1 thông báo, và chỉ gửi duy
    nhất 1 thông báo mà thôi. Tất nhiên là trong 1 thông báo này sẽ có chứa những thông báo riêng rẽ. Chi tết xem ở phần thử nghiệm tính năng group ở phần dưới.
    - group_wait: Sau khi một cảnh báo được taọ ra. Phải đợi khoảng thời gian này thì cảnh báo mới được gửi đi.
    - group_interval: Sau khi cảnh báo đầu tiên gửi đi, phải đợi 1 khoảng thời gian được cấu hình ở đây thì các cảnh báo sau mới được gửi đi.
    - repeat_interval: 3h: Sau khi cảnh báo được gửi đi thành công. Sau khoảng thời gian này, nếu vấn đề vẫn còn tồn tại,
    prometheus sẽ tiếp tục gửi đi cảnh báo sau khoảng thời gian này.

- Phần **routes:** Là nơi cấu hình các đường đi con. Prometheus sẽ dựa vào labels để chọn ra đường đi. Chúng ta có thể khai báo labels với tền đầy đủ hoặc sử dụng `regular expression`.
```sh
  routes:
  - match:
      severity: warning
    receiver: gmail
  - match:
      severity: critical
    receiver: slack
```
Nếu thông báo có nhãn `severity` với giá trị `warning` thì sẽ gửi đến đường đi gmail.

Nếu thông báo có nhãn `severity` với giá trị là `critical` thì sẽ gửi đến đường đi slack. 

Ngoài ra, ta có thể sử dụng `regular expression` để match các labels, để từ đó tìm ra đường đi.
```sh
  - match_re:
      service: ^(foo1|foo2|baz)$
    receiver: slack
```
=> Các labels có nhãn là foo1 hoặc foo2 hoặc baz sẽ được gửi đến slack.

- **Inhibition:** Có nghĩa là khi 1 cảnh báo được gửi đi, thì các cảnh báo phụ khác không cần phải gửi đi nữa.
```sh
inhibit_rules:
- source_match:
    severity: 'critical'
  target_match:
    severity: 'warning'
  # Apply inhibition if the alertname is the same.
  equal: ['alertname']
```
Ví dụ: Khi cảnh báo có nhãn `critical` được gửi đi, thì các cảnh báo `warning` không cần phải gửi đi nữa, áp dụng
với các cảnh báo có cùng `alertname`.

- **Phần receivers:** Là nơi sẽ cấu hình các thông tin nơi nhận.
```sh
receivers:
- name: 'default'
  email_configs:
  - to: 'sysadmin1@gmail.com, sysadmin2@gmail.com'
  slack_configs:
  - send_resolved: true
    username: 'monitor'
    channel: '#default'
    api_url: 'https://hooks.slack.com/services/xxxxxxxxxxx/xxxxxxxxxxx/xxxxxxxxxx'
```

Nơi nhận mặc đinh: Thông báo cùng lúc sẽ được gửi đến các địa chỉ sysadmin1@gmail.com, sysadmin2@gmail.com và channel default của kênh slack.

Ngoài ra ta có thể cấu hình bổ sung thêm các đường đi khác.
```sh
#receiver gmail
- name: 'gmail'
  email_configs:
  - to: 'man1@gmail.com'

#receiver man2
- name: 'slack'
  slack_configs:
    - send_resolved: true
      username: 'monitor'
      channel: '#general'
      api_url: 'https://hooks.slack.com/services/xxxxxxxxxxx/xxxxxxxxxxx/xxxxxxxxxx'
```

<a name="vande"></a>
#2. Dựa vào phần định tuyến đường đi, các vấn đề sau sẽ dễ dàng được giải quyết:
- Gửi cảnh báo cùng lúc đến nhiều nơi.
- Sau khi đẩy cảnh báo, nếu vẫn còn tồn tại vấn đề, sau một khoảng thời gian có thể tiếp tục đẩy cảnh báo đến người khác.
- Phân mức cảnh báo, gửi đến các đối tượng khác nhau: 
Việc phân mức cảnh báo sẽ là do mình tự đặt theo nhãn chứ không có sẵn các mức cảnh báo.
Ví dụ như với cảnh báo A, thì có nhãn là `warning`, cảnh báo B sẽ có nhãn là `critical`.
Thì trong phần cấu hình `route` đường đi của cảnh báo, mình sẽ dùng tùy chọn `match`, lọc ra các labels nào sẽ đi đường nào,có hỗ trợ match bằng cách dùng `regular expression`.
- Tính năng im lặng, không gửi cảnh báo nào trong 1 khoảng thời gian. Có hỗ trợ, cấu hình trên giao diện web của alertmanager. (Silences)
- Tính năng khi 1 cảnh báo được gửi đi thì có thể các cảnh báo khác không cần phải gửi đi nữa. (Inhibition)

<a name="group"></a>
#3. Thử nghiệm tính năng cảnh báo theo Group của Prometheus:
Mô hình: Prometheus-server monitor 2 targets:
- targets 1 - Hà Nội: MySQL replication: Service IO trong Replication (Up/Down).
- targets 2 - Hồ Chí Minh: Service MYSQL (Up/Down).

- Đây là rules phần cảnh báo.
```sh
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

Chú ý trong phần cấu hình trên, tôi đặt nhãn của 2 cảnh bảo đều là `severity` với giá trị là `warning`.

##3.1. Trường hợp 1: Để trống trong cấu hình Group_by: `Group_by []`
- Hà Nội: Stop IO thread.
- Hồ Chí Minh: Stop SQL service.

**=> 1 cảnh báo được gửi đi với nội dung là 2 service bị stop.**

![](https://raw.githubusercontent.com/linhlt247/networking-team/master/LinhLT/Prometheus%2Bgrafana/images/Screenshot%20-%2003032017%20-%2015%3A00%3A50.png)

![](https://github.com/linhlt247/tmp/blob/master/Screenshot%20-%2003032017%20-%2015:20:57.png?raw=true)

##3.2. Trường hợp 2: Cấu hình Group_by theo **alertname**: `Group_by['alertname']`
- Hà Nội: Stop IO thread.
- Hồ Chí Minh: Stop SQL service.

**=> 2 cảnh báo riêng rẻ được gửi đi.**

Giải thích: Bởi vì ở đây cấu hình Group_by theo alertname mà trong rules tôi cấu hình mỗi server có rules name khác nhau => 2 cảnh báo với 2 rules name khác nhau được gửi đi.

![](https://raw.githubusercontent.com/linhlt247/networking-team/master/LinhLT/Prometheus%2Bgrafana/images/Screenshot%20-%2003032017%20-%2013%3A57%3A55.png)

![](https://raw.githubusercontent.com/linhlt247/networking-team/master/LinhLT/Prometheus%2Bgrafana/images/Screenshot%20-%2003032017%20-%2015%3A21%3A04.png)

##3.3. Trường hợp 3: Cấu hình Group_by theo **severity**: `Group_by['severity']`
- Hà Nội: Stop IO thread.
- Hồ Chí Minh: Stop SQL service.

=> 1 cảnh báo được gửi đi với nội dung là 2 service bị down.

Giải thích: Bởi vì trong phần rules tôi cấu hình cảnh bảo 2 service đều có cùng mức cảnh báo là `severity = warning`: Do đó, nó gộp nhóm những cảnh báo có cùng mức cảnh báo và gửi vào 1 thông báo.

![](https://raw.githubusercontent.com/linhlt247/networking-team/master/LinhLT/Prometheus%2Bgrafana/images/Screenshot%20-%2003032017%20-%2014%3A08%3A05.png)


![](https://raw.githubusercontent.com/linhlt247/networking-team/master/LinhLT/Prometheus%2Bgrafana/images/Screenshot%20-%2003032017%20-%2015%3A21%3A16.png)

##3.4. Trường hợp 4: Comment Group_by: `#Group_by`
- Hà Nội: Stop IO thread.
- Hồ Chí Minh: Stop SQL service.

=> 1 cảnh báo được gửi đi với nội dung là 2 server bị stop.
![](https://raw.githubusercontent.com/linhlt247/networking-team/master/LinhLT/Prometheus%2Bgrafana/images/Screenshot%20-%2003032017%20-%2014%3A14%3A58.png)


##3.4 Kết Luận
- Khi không khai báo gì trong Group_by thì nó sẽ gom tất cả vào 1 thông báo.
- Khi Comment Group_by thì nó mặc định sẽ gom thông báo theo `alertname`.
```sh
On 23 August 2016 at 18:48, Alvaro Gil <zeva...@gmail.com> wrote:
OH, how I can just not grouping at all?

No, there's always grouping. This is as you want to try and minimise the number of notifications you get, as hundreds/thousands of notifications for a common issue isn't very useful.

Brian
```
link: https://groups.google.com/forum/#!searchin/prometheus-developers/group_by|sort:relevance/prometheus-developers/RQHDfPnZoso/oLUT-_HEBQAJ

- Group_by theo `labels` trong alert rules chứ không phải trong file config.

#4. File câu hình đầy đủ
```sh
global:
  # The smarthost and SMTP sender used for mail notifications.
  smtp_smarthost: 'localhost:25'
  smtp_from: 'alertmanager@example.org'
  smtp_auth_username: 'alertmanager'
  smtp_auth_password: 'password'
  # The auth token for Hipchat.
  hipchat_auth_token: '1234556789'
  # Alternative host for Hipchat.
  hipchat_url: 'https://hipchat.foobar.org/'

# The directory from which notification templates are read.
templates: 
- '/etc/alertmanager/template/*.tmpl'

# The root route on which each incoming alert enters.
route:
  # The labels by which incoming alerts are grouped together. For example,
  # multiple alerts coming in for cluster=A and alertname=LatencyHigh would
  # be batched into a single group.
  group_by: ['alertname', 'cluster', 'service']

  # When a new group of alerts is created by an incoming alert, wait at
  # least 'group_wait' to send the initial notification.
  # This way ensures that you get multiple alerts for the same group that start
  # firing shortly after another are batched together on the first 
  # notification.
  group_wait: 30s

  # When the first notification was sent, wait 'group_interval' to send a batch
  # of new alerts that started firing for that group.
  group_interval: 5m

  # If an alert has successfully been sent, wait 'repeat_interval' to
  # resend them.
  repeat_interval: 3h 

  # A default receiver
  receiver: team-X-mails

  # All the above attributes are inherited by all child routes and can 
  # overwritten on each.

  # The child route trees.
  routes:
  # This routes performs a regular expression match on alert labels to
  # catch alerts that are related to a list of services.
  - match_re:
      service: ^(foo1|foo2|baz)$
    receiver: team-X-mails
    # The service has a sub-route for critical alerts, any alerts
    # that do not match, i.e. severity != critical, fall-back to the
    # parent node and are sent to 'team-X-mails'
    routes:
    - match:
        severity: critical
      receiver: team-X-pager
  - match:
      service: files
    receiver: team-Y-mails

    routes:
    - match:
        severity: critical
      receiver: team-Y-pager

  # This route handles all alerts coming from a database service. If there's
  # no team to handle it, it defaults to the DB team.
  - match:
      service: database
    receiver: team-DB-pager
    # Also group alerts by affected database.
    group_by: [alertname, cluster, database]
    routes:
    - match:
        owner: team-X
      receiver: team-X-pager
    - match:
        owner: team-Y
      receiver: team-Y-pager


# Inhibition rules allow to mute a set of alerts given that another alert is
# firing.
# We use this to mute any warning-level notifications if the same alert is 
# already critical.
inhibit_rules:
- source_match:
    severity: 'critical'
  target_match:
    severity: 'warning'
  # Apply inhibition if the alertname is the same.
  equal: ['alertname', 'cluster', 'service']


receivers:
- name: 'team-X-mails'
  email_configs:
  - to: 'team-X+alerts@example.org'

- name: 'team-X-pager'
  email_configs:
  - to: 'team-X+alerts-critical@example.org'
  pagerduty_configs:
  - service_key: <team-X-key>

- name: 'team-Y-mails'
  email_configs:
  - to: 'team-Y+alerts@example.org'

- name: 'team-Y-pager'
  pagerduty_configs:
  - service_key: <team-Y-key>

- name: 'team-DB-pager'
  pagerduty_configs:
  - service_key: <team-DB-key>
- name: 'team-X-hipchat'
  hipchat_configs:
  - auth_token: <auth_token>
    room_id: 85
    message_format: html
    notify: true

```