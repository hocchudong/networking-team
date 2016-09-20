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
gamin ≥ 0.0.21
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
- Các thông số mặc định trong file `jail.conf`:

|Name|Giá trị mặc định|Ý nghĩa|
|:---:|:---:|:---:|
|ignoreip |ignoreip = 127.0.0.1/8 | Fail2Ban sẽ không ban địa chỉ ip này.|
|maxretry| 3 |Số lần thử tối đa|
|findtime| 600 sec | Số maxretry trong khoảng thời gian. Mặc định khi có 3 lần thử sai trong 600s thì bị ban |
|bantime|	600 sec | Khoảng thời gian ban địa chỉ ip. Sau khoảng thời gian này, ip sẽ được unban :v|
|destemail|destemail = root@localhost| Địa chỉ email mà fail2ban sẽ gửi 1 email thông báo khi có 1 địa chỉ ip bị ban.|
|sendername|sendername = Fail2Ban| Tên người gửi|

- Hành động mặc định trong file `jail.conf`:

|Name|Giá trị mặc định|Ý nghĩa|
|:---:|:---:|:---:|
|banaction|banaction = iptables-multiport| Hành động ban mặc định. Được dùng để định nghĩa biến `action_*`. Hành động này được quy định trong thư mục /etc/fail2ban/action.d|
|mta|mta = sendmail|chương trình mà fail2ban dùng để gửi email|
|protocol|protocol = tcp| Giao thức mặc định dùng để monitor fail2ban.
|chain|chain = INPUT| Chain nhảy đến chain của fail2ban khi sử dụng các hành động iptables-* |
|action|action = %(action_)s|Hành động mà fail2ban sẽ thực hiện, xác định thêm các thông số. Ví dụ hành động ban ip, hoặc ban ip đồng thời gửi email cảnh bảo.|

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
	- **maxretry = 6**: Số lần thử tối đa trước khi ban.

<a name="filter"></a>
##2.3 Filter expressions
- Thư mục `filter.d` chứa các file filter của các dịch vụ.
- Các file filter này được sử dụng để phát hiện break-in attempts, password failures, lọc ra các địa chỉ ip...

<a name="actions"></a>
##2.4 Actions
- Thư mục `action.d` chứa các file định nghĩa các hành động của các dịch vụ khác nhau.
- Khi đạt đến giới hạn mà ta quy định ở trên jail thì hành động này sẽ được thực thi. 
- Ví dụ: Chuyển cho IPTabels ban địa chỉ IP mà filter đã lọc được.

<a name="hoatdong"></a>
#3. Cơ chế hoạt động.

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
