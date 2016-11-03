#Hướng dẫn sử dụng zabbix monitor OpenVPN mô hình site to site.
#1. Cài đặt
#1.1 Import Template
- Các bạn tiến hành tải file `Template App OpenVPN.xml` và import và zabbix.
##1.2. Tải các file 
- Tải file `openvpn.conf` và đưa vào thư mục `/etc/zabbix/`
    Nội dung file này:
    ```sh
    {
    "data":[
        { "{#TUNNEL}":"tunnel1","{#TARGETIP}":"10.0.0.2","{#SOURCEIP}":"10.0.0.1" }
        ]
    }
    ```

    Các bạn cần thay đổi địa chỉ ip tunnel của cho phù hợp với mô hình của mình.

- Tải file `openvpn_check.conf` và đưa vào thư mục `/etc/zabbix/zabbix_agentd.d/`
- Tải file `zabbix` và đưa vào thư mục `/etc/sudoers.d/`
- Tải file `openvpn.sh` và đưa vào thư mục `/usr/local/lib/zabbix/externalscripts/`
    Chú ý, các bạn cần phân quyền cho phép thực thi file này.
   
    Và để thực thi được file này, các bạn cần phải cài đặt gói `fping`, bằng câu lệnh `apt-get install fping`

#2. Kết quả

![](http://image.prntscr.com/image/32230512d4984b0498eb3ad7c7dcff6d.png)

![](http://image.prntscr.com/image/ba66dada19974e0a8c2597d7c5d3f53a.png)

![](http://image.prntscr.com/image/3e10ab8c749647f5a05eb44b3327f199.png)

![](http://image.prntscr.com/image/0ea064e2120949eb9d47431895a56e13.png)