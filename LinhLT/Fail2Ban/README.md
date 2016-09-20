#Fail2Ban
- Fail2Ban quét các file log (Ví dụ:/var/log/apache/error_log) và chặn các địa chỉ IP mà có dấu hiệu nguy hiểm (đăng nhập thất bại nhiều lần, tìm kiếm các lỗi,..). 
- Fail2Ban sẽ cập nhật các rules của firewall (IPTables) để từ chối các địa chỉ IP trong một khoảng thời gian hoặc bất kỳ các hành động khác (Ví dụ như gửi email cảnh bảo cho người quản trị). 
- Fail2Ban có các filters cho những dịch vụ như apache, courier, ssh.

#Mục lục
- [1. Cài đặt](#caidat)
- [2. Cấu hình](#cauhinh)
	- [2.1 General settings](#general_setting)
	- [2.2 Jailing](#Jailing)
	- [2.3 Filter expressions](#filter)
	- [2.4 Actions](#actions)
- [3. Cơ chế hoạt động.](#hoatdong)
- [4. Câu Lệnh](#caulenh)
	- [4.1 fail2ban-server](#server)
	- [4.2 fail2ban-client](#client)
	- [4.3 fail2ban-regex](#regex)
- [5. Demo](#demo)
- [6. Nâng cao - Viết filter, action cho một ứng dụng???](#nangcao)
- [7. Tham khảo](#thamkhao)


<a name="caidat"></a>
#1. Cài đặt
- Yêu cầu:

```sh
python ≥ 2.3
```
- Cài đặt trên Ubuntu

```sh
apt-get install fail2ban
```
- Thư mục mặc định khi cài đặt trên Ubuntu là `/etc/fail2ban/`

- Cài đặt trên CentOS

```sh
yum install fail2ban
```

- Installing from sources on a GNU/Linux system

```sh
git clone git://github.com/fail2ban/fail2ban.git
cd fail2ban-0.10.0
python setup.py install
```
<a name="cauhinh"></a>
#2. Cấu hình
- Fail2Ban gồm 2 thành phần là client và server. Server có nhiệm vụ lắng nghe. Còn client gửi các lệnh đến server.
- Mặc định trên ubuntu, khi cài đặt thì thư mục chứa các file cấu hình mặc định của fail2ban là `/etc/fail2ban/`
- Cấu trúc thư mục: `/etc/fail2ban/`

```sh
├── action.d
│   ├── dummy.conf
│   ├── hostsdeny.conf
│   ├── iptables.conf
│   ├── mail-whois.conf
│   ├── mail.conf
│   └── shorewall.conf
├── fail2ban.conf
├── fail2ban.local
├── filter.d
│   ├── apache-auth.conf
│   ├── apache-noscript.conf
│   ├── couriersmtp.conf
│   ├── postfix.conf
│   ├── proftpd.conf
│   ├── qmail.conf
│   ├── sasl.conf
│   ├── sshd.conf
│   └── vsftpd.conf
├── jail.conf
└── jail.local
└── jail.d
```


- Mỗi file `.conf` có thể được ghi đè bởi file cùng tên có đuôi `.local`. 
- Đầu tiên, file `.conf` được đọc, sau đó là file có đuôi `.local`. Như vậy, file `.local` không cần phải include mọi thứ tương
ứng với file `.conf`. File này chỉ nên chứa những thiết lập mà bạn muốn ghi đè lên.
- Bạn nên thực hiện sửa đổi ở file `.local`. Nó sẽ giúp ta tránh một số lỗi không đáng có khi tiến hành nâng cấp. 

<a name="general_setting"></a>
##2.1 General settings
- File cấu hình chính của Fail2Ban là `fail2ban.conf`, dùng để cấu hình dịch vụ fail2ban-server.
- Trong file này, ta cấu hình các thông số là:
	- logging level
	- logtarget
	- socket
	- pidfile

- Logging level: Đặt mức log khi xuất ra. Có các mức sau:
	- 1 = ERROR
	- 2 = WARN
	- 3 = INFO
	- 4 = DEBUG
	```sh
	loglevel = 3
	```

- logtarget: Đặt log target cho fail2ban. fail2ban sẽ xuất các log của mình ra đây. Target có thể là một file, SYSLOG, STDERR hoặc STDOUT.
	```sh
	logtarget = /var/log/fail2ban.log
	```

- socket: Đặt socket file cho fail2ban. Mặc định là `/var/run/fail2ban/fail2ban.sock`.
```sh
socket = /var/run/fail2ban/fail2ban.sock
```

- pidfile: Đặt PID file. Sử dụng để lưu trức process ID của fail2ban server. Mặc định là `/var/run/fail2ban/fail2ban.pid`.
```sh
pidfile = /var/run/fail2ban/fail2ban.pid
```

<a name="jailing"></a>
##2.2 Jailing
- Jail định nghĩa chính sách cho những ứng dụng mà fail2ban sẽ gây ra một hành động bảo vệ cho ứng dụng đó.
- File cấu hình jail mặc định `/etc/fail2ban/jail.conf`. Trong file này, một số ứng dụng phổ biến được định nghĩa như apache, ssh, dovecot, mysql,...
- Ta còn có thể đưa mỗi dịch vụ ra một file jail riêng, nằm trong thư mục `jail.d` để tiện quản lý.
- Mỗi jail dựa trên bộ lọc ứng dụng `(/etc/fail2ban/fileter.d)` để phát hiện ra các cuộc tấn công.
###2.2.1 Các thông số mặc định.
```sh
[DEFAULT]

ignoreip = 127.0.0.1/8
bantime = 600
findtime = 600
maxretry = 3
backend = auto
usedns = warn
destemail = root@localhost
sendername = Fail2Ban
banaction = iptables-multiport
mta = sendmail
protocol = tcp
chain = INPUT
action_ = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
action_mw = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
          %(mta)s-whois[name=%(__name__)s, dest="%(destemail)s", protocol="%(protocol)s", chain="%(chain)s", sendername="%(sendername)s"]
action_mwl = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
           %(mta)s-whois-lines[name=%(__name__)s, dest="%(destemail)s", logpath=%(logpath)s, chain="%(chain)s", sendername="%(sendername)s"]
action = %(action_)s
```

- **ignoreip**: fail2ban sẽ bỏ qua địa chỉ ip này. Tức có nghĩa là mặc dù có địa chỉ ip này trong danh sách log mà nó phát hiện được nhưng fail2ban sẽ không ban địa chỉ ip này.
	Giá trị mặc định là 127.0.0.1/8, tức là chính nó.
- **bantime**: Thời gian, tính bằng giây. Là khoảng thời gian mà ip sẽ bị ban. Mặc định là 600s = 10 phút.
- **findtime**, **maxretry**: Số lần thử tối đa trong khoảng thời gian findtime (tính bằng giây).
	Ví dụ với dịch vụ ssh, với giá trị mặc định (maxretry=3, findtime=600s) thì trong vòng 600s, bạn chỉ được phép đăng nhập thất bại 3 lần.
- **backend**: Mục này quy định cách mà fail2ban sẽ theo dõi log của bạn như thế nào. Ở đây có các tùy chọn là `pyinotify` hoặc `gamin` hoặc `polling` hoặc `auto`.
	- **pyinotify**: Pyinotify is a Python module for monitoring filesystems changes. Pyinotify relies on a Linux Kernel feature (merged in kernel 2.6.13) called inotify.
	- **gamin**: Gamin is a file and directory monitoring system defined to be a subset of the FAM (File Alteration Monitor) system. This is a service provided by a library which allows to detect when a file or a directory has been modified.
	- **polling**: sử dụng polling algorithm. (@@!)
	- **auto**:  fail2ban sẽ thử lần lượt các backend là pyinotify, gamin, polling.
- **usedns**: Điều này xác định liệu dịch ngược DNS có được sử dụng để giúp thực hiện các lệnh cấm hay không. (dịch ngược từ ip sang hostname). Nó có các options:
	- **yes**: Được sử dụng :))
	- **warn**: Sẽ được thực hiện nhưng nó sẽ log lại thông tin dưới dạng `warn`.
	- **no**: Không sử dụng. :v
- **destemail**: Địa chi email để fail2ban gửi cảnh bảo đến.
- **sendername**: Tên người gửi :)).
- **banaction**: Hành động sẽ sử dụng khi đạt đến giới hạn (maxretry, findtime). Hành động này được quy định trong thư mục `/etc/fail2ban/action.d`
- **mta**: mail transfer agent được sử dụng để gửi email.
- **protocol**: Chỉ ra giao thức trong lệnh cấm.
- **chain**: Chain mà nó sẽ được cấu hình để gửi các lưu lượng đến fail2ban chain.
- Các lệnh **action** ở dưới sẽ gọi đến hành động `banaction` cùng với danh sách các tham số cần thiết cho việc ban.

###2.2.2 Các thông số cho dịch vụ cụ thể.
- Bên dưới phần mặc định, có phần cho các dịch vụ cụ thể mà có thể được sử dụng để ghi đè lên các thiết lập mặc định
- Mỗi dịch vụ quy định như thế này:

```sh
[service_name]
```
- Cho phép kích hoạt dịch vụ này.

```sh
enabled = true
```

- phân tích SSH jain trong file `jail.conf`:

```sh
[ssh]
enabled   = true
port      = ssh
filter    = sshd
logpath   = /var/log/auth.log
maxretry  = 6
```
- Giải thích các thông số:
	- **[ssh]**: Tên jail.
	- **enabled = true**: jail này có hoạt động hay không.
	- **port = ssh**: Cổng cần bảo vệ.
	- **filter = sshd**: Chỉ ra file filter trong thư mục (/etc/fail2ban/fileter.d), bao gồm các quy tắc phân tích log để phát hiện cuộc tấn công.
	- **logpath = /var/log/auth.log**: Đường dẫn file log mà filter dùng để đọc.
	- **maxretry = 6**: Số lần thử tối đa trước khi ban. Ghi đè tùy chọn mặc định ở trên.
	- Ở đây, các thông số khác không được quy định, nó sẽ dùng các thông số mặc định ở trên.

<a name="filter"></a>
##2.3 Filter expressions
- Thư mục `filter.d` chứa các file filter của các dịch vụ.
- Các file filter này được sử dụng để phát hiện break-in attempts, password failures, lọc ra các địa chỉ ip...
- Các tập tin lọc sẽ xác định các đường mà fail2ban sẽ tìm kiếm trong các file bản ghi để xác định đặc điểm vi phạm.
- Các tập tin hành động thực hiện tất cả các hành động cần thiết, từ xây dựng một cấu trúc tường lửa khi dịch vụ bắt đầu,
để thêm và xóa các quy tắc, và xóa cấu trúc tường lửa khi dịch vụ dừng.

- Ví dụ phân tích file **sshd.config**: `/etc/fail2ban/filter.d/sshd.conf`

```sh
[INCLUDES]

before = common.conf

[Definition]

_daemon = sshd
failregex = ^%(__prefix_line)s(?:error: PAM: )?[aA]uthentication (?:failure|error) for .* from <HOST>( via \S+)?\s*$
        ^%(__prefix_line)s(?:error: PAM: )?User not known to the underlying authentication module for .* from <HOST>\s*$
        ^%(__prefix_line)sFailed \S+ for .*? from <HOST>(?: port \d*)?(?: ssh\d*)?(: (ruser .*|(\S+ ID \S+ \(serial \d+\) CA )?\S+ %(__md5hex)s(, client user ".*", client host ".*")?))?\s*$
        ^%(__prefix_line)sROOT LOGIN REFUSED.* FROM <HOST>\s*$
        ^%(__prefix_line)s[iI](?:llegal|nvalid) user .* from <HOST>\s*$
        ^%(__prefix_line)sUser .+ from <HOST> not allowed because not listed in AllowUsers\s*$
        ^%(__prefix_line)sUser .+ from <HOST> not allowed because listed in DenyUsers\s*$
        ^%(__prefix_line)sUser .+ from <HOST> not allowed because not in any group\s*$
        ^%(__prefix_line)srefused connect from \S+ \(<HOST>\)\s*$
        ^%(__prefix_line)sUser .+ from <HOST> not allowed because a group is listed in DenyGroups\s*$
        ^%(__prefix_line)sUser .+ from <HOST> not allowed because none of user's groups are listed in AllowGroups\s*$
ignoreregex =
```



<a name="actions"></a>
##2.4 Actions
- Thư mục `action.d` chứa các file định nghĩa các hành động của các dịch vụ khác nhau.
- Khi đạt đến giới hạn mà ta quy định ở trên jail thì hành động này sẽ được thực thi. 
- Tập tin này có trách nhiệm thiết lập tường lửa, với một cấu trúc cho phép dễ dàng thay đổi việc cấm các host độc hại, thêm và xóa các host khi cần thiết.
- Ví dụ phân tích file **iptables-multiport.conf** `/etc/fail2ban/action.d/iptables-multiport.conf`
```sh
[INCLUDES]
before = iptables-blocktype.conf

[Definition]
actionstart = iptables -N fail2ban-<name>
              iptables -A fail2ban-<name> -j RETURN
              iptables -I <chain> -p <protocol> -m multiport --dports <port> -j fail2ban-<name>

actionstop = iptables -D <chain> -p <protocol> -m multiport --dports <port> -j fail2ban-<name>

actioncheck = iptables -n -L <chain> | grep -a 'fail2ban-<name>[ \t]'

actionban = iptables -I fail2ban-<name> 1 -s <ip> -j <blocktype>

actionunban = iptables -D fail2ban-<name> -s <ip> -j <blocktype>

[Init]
name = default
port = ssh
protocol = tcp
chain = INPUT
```


<a name="hoatdong"></a>
#3. Cơ chế hoạt động.
- Khi fail2ban được cấu hình để theo dõi các bản ghi của một dịch vụ. Nó sẽ nhìn vào **filter** đã được cấu hình cụ thể cho dịch vụ đó.
- Các **filter** được thiết kế để xác định lỗi xác thực cho dịch vụ cụ thể thông qua việc sử dụng các biểu thức chính quy phức tạp, gọi là **failregex**.
- Khi một dòng trong file log của dịch vụ đó trùng với **failregex** trong **filter**, **action** được định nghĩa cho dịch vụ đó sẽ được thực thi.
- **action** có thể được cấu hình để làm nhiều việc khác nhau. Hành động mặc định là sẽ cấm các địa chỉ ip bởi rules của iptables. 

##3.1 Loading the Initial Configuration Files
- Đầu tiên, tập tin `fail2ban.conf` được đọc để xác định các điều kiện mà các quá trình chính nên hoạt động theo.
Nó tạo ra các socket pid, và file log nếu cần thiết và bắt đầu sử dụng chúng.
- Tiếp theo, fail2ban đọc file `jail.conf` để biết chi tiết cấu hình.
Nó sẽ đọc tất cả các tập tin trong thư mục `jail.d` mà kết thúc bằng đuôi `conf.` Nó cho biết thêm các thiết lập được tìm thấy trong các tập tin này để cấu hình nội bộ của mình, đưa ra ưu tiên giá trị mới trên những giá trị mô tả trong file `jail.conf`.
- Sau đó nó tìm kiếm một tập tin `jail.local` và lặp đi lặp lại quá trình này, thích ứng với các giá trị mới.
Cuối cùng, nó tìm kiếm trong thư mục `jail.d` một lần nữa, đọc trong file thứ tự chữ cái kết thúc bằng `.local.`.
- fail2ban bây giờ có một tập hợp các chỉ thị được nạp vào bộ nhớ mà đại diện cho một sự kết hợp của tất cả các tập tin mà nó tìm thấy.
- Nó kiểm tra từng phần và tìm kiếm một `enabled = true`.
Nếu nó tìm thấy, nó sử dụng các thông số xác định theo phần đó để xây dựng một chính sách và quyết định những hành động được yêu cầu.
Bất kỳ tham số mà không được tìm thấy trong phần của dịch vụ thì sẽ sử dụng các thông số định nghĩa trong phần **[DEFAULT]**.

##3.2 Parsing the Action Files to Determine Starting Actions
- Fail2ban tìm kiếm một `action` để thực hiện chính sách ban/unbanning. Nếu nó không tìm thấy, nó sẽ thực hiện theo hành động mặc định được xác định ở trên.
- Các chỉ thị hành động bao gồm tên của tập tin hành động (s) sẽ được đọc, cũng như các giá trị quan trọng như tên,...
Tên của dịch vụ thường được dùng với biến `__name__`. 
- Fail2ban sau đó sử dụng thông tin này để tìm các tập tin liên quan trong thư mục `action.d`.
Trước tiên nó sẽ tìm file `action` kết thúc bởi `.conf` và sau đó sửa đổi các thông tin tìm được ở đó với
các thông số trong một tập tin `.local` đi kèm. (cũng được tìm thấy trong thư mục `action.d.`)
- Nó phân tích các tập tin để xác định các hành động mà nó cần phải làm ngay bây giờ.
Nó đọc giá trị `actionstart` để xem các hành động cần làm để thiết lập môi trường.
Điều này thường bao gồm việc tạo ra một cấu trúc tường lửa để chứa quy tắc cấm trong tương lai.

- Các hành động được xác định trong tập tin này sử dụng các tham số được truyền cho nó từ `action`.
Nó sẽ sử dụng những giá trị này để tự động tạo ra các quy tắc thích hợp.
Nếu một biến nào đó đã không được thiết lập, nó có thể nhìn vào các giá trị mặc định trong các tập tin hành động để điền vào chỗ trống.

##3.3 Parsing the Filter Files to Determine Filtering Rules
- Fail2ban sẽ tìm kiếm trong thư mục `filter.d` để tìm tập tin lọc phù hợp với kết thúc bằng `.conf`.
Nó đọc tập tin này để xác định các các trường mà có thể được sử dụng để **match** với dòng vi phạm.
Sau đó nó tìm kiếm một tập tin lọc phù hợp với kết thúc với `.local` để có cần sửa đổi thông tin gì không.
- Nó sử dụng các biểu thức chính quy được xác định trong các tập tin `filter` để có thể đọc `file log` của dịch vụ.
Mỗi dòng `failregex` được định nghĩa trong file `filter.d` được so sánh với mỗi dòng mới trong file log.
- Nếu các biểu thức chính quy trả về giá trị **match** (trùng), nó sẽ kiểm tra dòng này với các biểu thức
 chính quy được xác định bởi các `ignoreregex`. Nếu điều này cũng phù hợp, fail2ban bỏ qua nó.
 Nếu dòng phù hợp với một biểu thức trong `failregex` nhưng không phù hợp với một biểu thức trong `ignoreregex`,
Bộ đếm tăng lên 1 cho `client` gây ra dòng này và một dấu thời gian liên quan được tạo ra cho sự kiện này.

- Khi cửa sổ thời gian được thiết lập bởi các tham số `findtime` trong file `jail.*` đạt đến. (được xác định bởi các dấu thời gian sự kiện),
các truy cập nội bộ được giảm đi một lần và sự kiện này không còn được coi là có liên quan đến các chính sách cấm.

- Nếu trong quá trình thời gian, xác thực thất bại, bộ đếm sẽ được tăng lên. 
Nếu truy cập đạt giá trị được thiết lập bởi các tham số `maxretry` trong cửa sổ cấu hình của thời gian,
fail2ban sẽ thực hiện một lệnh cấm bằng cách gọi các hành động `actioncheck` cho dịch vụ theo quy định tại các `action.d/service`. 
Điều này là để xác định xem hành động `actionstart` đã được thiết lập các cơ cấu cần thiết hay chưa.
Sau đó nó gọi hành động `actionban` cấm `client`vi phạm. Nó đặt ra một dấu thời gian cho sự kiện này.

- Khi số lượng thời gian đã trôi qua mà đã được chỉ định bởi tham số `bantime`
 fail2ban bỏ cấm khách hàng bằng cách gọi các hành động `actionunban`.

- Khi dịch vụ fail2ban dừng lại, nó cố gắng phá bỏ các quy tắc tường lửa mà nó được tạo ra bằng cách gọi các hành động `actionstop`.
Điều này thường xóa các chuỗi có chứa các quy tắc fail2ban và loại bỏ các quy tắc từ chuỗi INPUT đã gây ra để chuyển các **traffic** đến chuỗi đó.

<a name="caulenh"></a>
#4. Câu Lệnh

<a name="server"></a>
##4.1 fail2ban-server
- fail2ban server là đa luồng và lắng nghe lệnh trên Unix socket. Nó không biết về các file cấu hình. 
- Khi khởi động, server ở trạng thái `default` và không có `jails` nào được định nghĩa.
```sh
-b                   start in background
-f                   start in foreground
-s <FILE>            socket path
-x                   force execution of the server
-h, --help           display this help message
-V, --version        print the version
```
- fail2ban-server thường được sử dụng trong trường hợp debugging lỗi.

<a name="client"></a>
##4.2 fail2ban-client 
- is the frontend of Fail2ban.
- Nó kết nối đến file socket của server và gửi các lệnh đến server.
- fail2ban-client có thể đọc các file config và gửi đến server.

```sh
-c <DIR>                configuration directory
-s <FILE>               socket path
-d                      dump configuration. For debugging
-i                      interactive mode
-v                      increase verbosity
-q                      decrease verbosity
-x                      force execution of the server
-h, --help              display this help message
-V, --version           print the version
```

- option `-s <FILE> ` được sử dụng để đặt đường dẫn file socket. Nó sẽ ghi đè tùy chọn socket được cấu hình trong file `fail2ban.conf`.
- Thư mục mặc định cấu hình là `/etc/fail2ban`, tuy nhiên, bạn có thể chỉ định đường dẫn khác với tùy chọn `-c <DIR>`

- Một số câu lệnh đơn giản:

```sh
start: starts the server and the jails
reloads: the configuration
reload *<JAIL>*: reloads the jail <JAIL>
stop: stops all jails and terminate the server
status: gets the current status of the server
ping: tests if the server is alive
```

- LOGGING

```sh
set loglevel *<LEVEL>*: sets logging level to <LEVEL>. 0 is minimal, 4 is debug
get loglevel: gets the logging level
set logtarget *<TARGET>*: sets logging target to <TARGET>. Can be STDOUT, STDERR, SYSLOG or a file
get logtarget: gets logging target
```

- JAIL CONTROL

```sh
add <JAIL> <BACKEND>: creates <JAIL> using <BACKEND>
start <JAIL>: starts the jail <JAIL>
stop <JAIL>: stops the jail <JAIL>. The jail is removed
status <JAIL>: gets the current status of <JAIL>
```

- JAIL CONFIGURATION

```sh
set <JAIL> idle on/off: sets the idle state of <JAIL>
set <JAIL> addignoreip <IP>: adds <IP> to the ignore list of <JAIL>
set <JAIL> delignoreip <IP>: removes <IP> from the ignore list of <JAIL>
......
```

- JAIL INFORMATION

```sh
get <JAIL> logpath: gets the list of the monitored files for <JAIL>
get <JAIL> ignoreip: gets the list of ignored IP addresses for <JAIL>
get <JAIL> timeregex: gets the regular expression used for the time detection for <JAIL>
......
```

<a name="regex"></a>
##4.3 fail2ban-regex
- Dùng để thử nghiệm các biểu thức chính quy. (This tools can test regular expressions for "fail2ban".)

```sh
fail2ban-regex [OPTIONS] <LOG> <REGEX> [IGNOREREGEX]
```
- Các Options: 

```sh
-h, --help: display this help message
-V, --version: print the version
```
- LOG

```sh
string:a string representing a log line
filename:path to a log file (/var/log/auth.log)
```

- REGEX

```sh
string: a string representing a 'failregex'
filename: path to a filter file (filter.d/sshd.conf)
```

- IgnoreRegex:

```sh
string: a string representing an 'ignoreregex'
filename: path to a filter file (filter.d/sshd.conf)
```
<a name="demo"></a>
#5. Demo

<a name="nangcao"></a>
#6. Nâng cao - Viết filter, action cho một ứng dụng???
 
<a name="thamkhao"></a>
#7. Tham khảo
- http://www.fail2ban.org/wiki/index.php/MANUAL_0_8
- https://linux.die.net/man/1/fail2ban-server
- https://linux.die.net/man/1/fail2ban-client
- https://linux.die.net/man/1/fail2ban-regex
- http://xmodulo.com/configure-fail2ban-apache-http-server.html
- https://www.digitalocean.com/community/tutorials/how-fail2ban-works-to-protect-services-on-a-linux-server
