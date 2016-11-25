#Note IPSEC

Note những phần quan trọng trong giao thức ipsec.
#1. Tổng quan về IP SEC

- Giao thức IPsec được làm việc tại tầng Network Layer – layer 3 của mô hình OSI.
- Các giao thức bảo mật trên Internet khác như SSL, TLS và SSH, được thực hiện từ tầng transport layer trở lên (Từ tầng 4 tới tầng 7 mô hình OSI).
- Điều này tạo ra tính mềm dẻo cho IPsec, giao thức này có thể hoạt động từ tầng 4 với TCP, UDP, hầu hết các giao thức sử dụng tại tầng này.
- IPsec có một tính năng cao cấp hơn SSL và các phương thức khác hoạt động tại các tầng trên của mô hình OSI. Với một ứng dụng sử dụng IPsec mã (code) không bị thay đổi, nhưng nếu ứng dụng đó bắt buộc sử dụng SSL và các giao thức bảo mật trên các tầng trên trong mô hình OSI thì đoạn mã ứng dụng đó sẽ bị thay đổi lớn.


#2. Có hai mode khi thực hiện IPsec đó là: Transport mode và tunnel mode:
##2.1 Transport mode
- Trong Transport mode, chỉ những dữ liệu bạn giao tiếp các gói tin được mã hoá và/hoặc xác thực. Trong quá trình routing, cả IP header đều không bị chỉnh sửa hay mã hoá; tuy nhiên khi authentication header được sử dụng, địa chỉ IP không thể biết được, bởi các thông tin đã bị hash (băm). Transport và application layers thường được bảo mật bởi hàm băm (hash), và chúng không thể chỉnh sửa (ví dụ như port number). Transport mode sử dụng trong tình huống giao tiếp host-to-host.

- Transport mode secures a point to point connection (Router1 – Router2)

Điều này có nghĩa là đóng gói các thông tin trong IPsec cho NAT traversal được định nghĩa bởi các thông tin trong tài liệu của RFC bởi NAT-T.

##2.2 Tunnel mode
- Trong tunnel mode, toàn bộ gói IP (bao gồm cả data và header) sẽ được mã hoá và xác thực. Nó phải được đóng gói lại trong một dạng IP packet khác trong quá trình routing của router. Tunnel mode được sử dụng trong giao tiếp network-to-network (hay giữa các routers với nhau), hoặc host-to-network và host-to-host trên internet.

- Tunnel mode secures subnet to subnet (LAN1 – LAN2)

#3. Có hai giao thức được phát triển và cung cấp bảo mật cho các gói tin của cả hai phiên bản IPv4 và IPv6:

- IP Authentication Header giúp đảm bảo tính toàn vẹn và cung cấp xác thực.

- IP Encapsulating Security Payload cung cấp bảo mật, và là option bạn có thể lựa chọn cả tính năng authentication và Integrity đảm bảo tính toàn vẹn dữ liệu.


Thuật toán mã hoá được sử dụng trong IPsec bao gồm HMAC-SHA1 cho tính toàn vẹn dữ liệu (integrity protection), và thuật toán TripleDES-CBC và AES-CBC cho mã mã hoá và đảm bảo độ an toàn của gói tin. Toàn bộ thuật toán này được thể hiện trong RFC 4305.


##3.1 a. Authentication Header (AH)

AH được sử dụng trong các kết nối không có tính đảm bảo dữ liệu. Hơn nữa nó là lựa chọn nhằm chống lại các tấn công replay attack bằng cách sử dụng công nghệ tấn công sliding windows và discarding older packets. AH bảo vệ quá trình truyền dữ liệu khi sử dụng IP. Trong IPv4, IP header có bao gồm TOS, Flags, Fragment Offset, TTL, và Header Checksum. AH thực hiện trực tiếp trong phần đầu tiên của gói tin IP. dưới đây là mô hình của AH header.


##3.2 b. Encapsulating Security Payload (ESP)

Giao thức ESP cung cấp xác thực, độ toàn vẹn, đảm bảo tính bảo mật cho gói tin. ESP cũng hỗ trợ tính năng cấu hình sử dụng trong tính huống chỉ cần bảo mã hoá và chỉ cần cho authentication, nhưng sử dụng mã hoá mà không yêu cầu xác thực không đảm bảo tính bảo mật. Không như AH, header của gói tin IP, bao gồm các option khác. ESP thực hiện trên top IP sử dụng giao thức IP và mang số hiệu 50 và AH mang số hiệu 51.


##3.3 c.  IKE (Internet Key Exchange)

IKE là giao thức thực hiện quá trình trao đổi khóa và thỏa thuận các thông số bảo mật với nhau như: mã hóa thế nào, mã hóa bằng thuật toán gì, bau lâu trao đổi khóa 1 lần. Sau khi trao đổi xong thì sẽ có được một “hợp đồng” giữa 2 đầu cuối, khi đó IPSec SA (Security Association) được tạo ra.

SA là những thông số bảo mật đã được thỏa thuận thành công, các thông số SA này sẽ được lưu trong cơ sở dữ liệu của SA

Trong quá trình trao đổi khóa thì IKE dùng thuật toán mã hóa đối xứng, những khóa này sẽ được thay đổi theo thời gian. Đây là đặc tính rất hay của IKE, giúp hạn chế trình trạng bẻ khóa của các attacker.

###3.3.1 ISAKMP
IKE còn dùng 2 giao thức khác để chứng thực đầu cuối và tạo khóa: ISAKMP (Internet Security Association and Key Management Protocol) và Oakley.
– ISAKMP: là giao thức thực hiện việc thiết lập, thỏa thuận và quản lý chính sách bảo mật SA
– Oakley: là giao thức làm nhiệm vụ chứng thực khóa, bản chất là dùng thuật toán Diffie-Hellman để trao đổi khóa bí mật thông qua môi trường chưa bảo mật.
Giao thức IKE dùng UDP port 500.
Các giai đoạn (phase) hoạt động của IKE

Giai đoạn hoạt động của IKE cũng được xem tương tự như là quá trình bắt tay trong TCP/IP. Quá trình hoạt động của IKE được chia ra làm 2 phase chính: Phase 1 và Phase 2, cả hai phase này nhằm thiết lập kênh truyền an toàn giữa 2 điểm. Ngoài phase 1 và phase 2 còn có phase 1,5 tùy chọn.



IPsec được thực hiện trong nhân với các trình quản lý các key và quá trình thương lượng bảo mật ISAKMP/IKE từ người dùng. Tuy nhiên một chuẩn giao diện cho quản lý key, nó có thể được điều khiển bởi nhân của IPsec.



#II. CÁCH THỨC HOẠT ĐỘNG CỦA IP SEC :

##– Giai đoạn 1 – đàm phán và tạo tunnel (đường ngầm dữ liệu):

Hai hệ thống khi giao tiếp với nhau, trước tiên, chúng sẽ trao đổi với nhau phương thức Authentication.
Việc đàm phát sẽ thông qua module Internet Key Exchange (IKE). IKE là sự kết hợp của hai giao thức: Internet Security Association and Key Management Protocol (ISAKMP) và Oakley Key Determination Protocol.
Nếu các phương thức khác nhau (ví dụ một bên dùng mã hóa Kerberos, một bên dùng chuỗi text) thì việc đàm phán sẽ kết thúc không thành công. Lưu ý là khi hai hệ thống sử dụng chuỗi nhưng có nội dung khác nhau thì cũng được coi là hai phương thức đàm phát khác nhau. Khi đã không thành công, việc kết nối của hai hệ thống coi như kết thúc.
Lúc này, dùng chương trình bắt gói để theo dõi, ta chỉ có thể thấy được các gói ISAKMP mà sẽ không thấy được các gói chứa dữ liệu AH, và ESP.
Khi việc đàm phán thành công, IKE sẽ tạo ra một tunnel để dùng cho việc trao đổi giữ liệu giữa hai hệ thống.

##– Giai đoạn 2 – trao đổi dữ liệu:
Trong giai đoạn này, hai hệ thống sẽ sử dụng “đường ngầm” đã tạo ra ở giai đoạn một để trao đổi giữ liệu. Trong giai đoạn này, Một module nữa là IP SEC Driver nằm ngay trong tầng Network sẽ chịu trách nhiệm mã hóa các dữ liệu được truyền đi.





#Tài liệu tham khảo
- http://thonghoang.com/bao-mat/ipsec-ip-security-la-gi.html
- https://norkvalhalla.wordpress.com/2013/06/16/khai-quat-ipsec/
- https://duongtuanan.wordpress.com/2010/10/29/870/
- http://www.slashroot.in/what-ipsec-and-how-ipsec-does-job-securing-data-communication