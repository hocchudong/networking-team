#Tổng quan về VPN.

**Mục Lục**

[I. VPN là gì.] (#whatisvpn)

[II. Các công nghệ VPN.] (#caccongnghe)

[III. Các loại VPN.] (#cacloai)

[IV. Những ưu điểm nổi trội của VPN.] (#uudiem)
 <ul>
  <li>[1. Tính tin cậy.] (#tincay)</li>
  <li>[2. Tính toàn vẹn.] (#toanven)</li>
  <li>[3. Chứng thực.] (#chungthuc)</li>
  <li>[4. Chống tấn công lặp lại.] (#chongtanconglaplai)</li>
 </ul>

[V. Mã hóa khối.] (#mahoakhoi)

[VI. Thuật toán mã hóa đối xứng.] (#mahoadoixung)

[VII. Thuật toán mã hóa bất đối xứng.] (#mahoabatdoixung)

[VIII. Hàm băm.] (#hambam)

[IX. HMAC] (#hmac)

[X. Chữ ký số.] (#chukyso)

[XI. Quản lý key.] (#quanlykey)

[XII. Sơ lược về IPSEC và SSL.] (#ipsecvassl)
 <ul>
  <li>[1. IPSEC] (#ipsec)</li>
  <li>[2. SSL] (#ssl)</li>
 </ul>

****

<a name="whatisvpn"></a>
##I. VPN là gì?

- Mạng riêng ảo hay còn được biết đến với từ viết tắt VPN, đây không phải là một khái niệm mới trong công nghệ mạng. 
VPN có thể được đinh nghĩa như là một dịch vụ mạng ảo được triển khai trên cơ sở hạ tầng của hệ thống mạng công cộng với 
mục đích tiết kiệm chi phí cho các kết nối điểm-điểm. Một cuộc điện thoại giữa hai cá nhân là ví dụ đơn giản nhất mô tả một 
kết nối riêng ảo trên mạng điện thoại công cộng. Hai đặc điểm quan trọng của công nghệ VPN là ''riêng'' và ''ảo" tương ứng 
với hai thuật ngữ tiếng anh (Virtual and Private). VPN có thể xuất hiện tại bất cứ lớp nào trong mô hình OSI, VPN là sự cải 
tiến cơ sở hạ tầng mạng WAN, làm thay đổi và làm tăng thêm tích chất của mạng cục bộ cho mạng WAN.

![vpn1](http://i.imgur.com/c8aK4sy.png)

<a name="caccongnghe"></a>
##II. Các công nghệ VPN.

- VPN sử dụng một số công nghệ như :
 <ul>
  <li>IPSEC : Thực hiện bảo mật cho gói tin IP ở Layer 3 của mô hình OSI, có thể dùng cho site-to-site VPN hoặc remote-access 
  VPN.</li>
  <li>SSL : Secure Socket Layer thực hiện bảo mật cho TCP session tại Layer 4 của mô hình OSI, và có thể dùng cho remote-access 
  VPN (cũng như dùng để truy cập an toàn một web server thông qua HTTPS).</li>
  <li>MPLS : MPLS Layer 3 VPN mặc định không có mã hóa. Ta có thể sử dụng IPsec chung với MPLS VPN.</li>
 </ul>

<a name="cacloai"></a>
##III. Các loại VPN.

- VPN có thể được chia thành 2 loại chính là remote-access và site-to-site:
 <ul>
  <li>Remote-access VPN :  Một số user có thể cần tạo một kết nối VPN từ PC của họ đến trụ sở (hoặc đến nơi mà họ muốn). Loại này 
  gọi là remote-access VPN. Remote-access VPN có thể sử dụng công nghệ IPsec hoặc SSL.</li>
  <li>Site-to-site VPN :  Một số công ty có 2 hoặc nhiều sites, và họ muốn các sites này có thể kết nối an toàn với nhau. Loại này 
  gọi là site-to-site VPN. Site-to-site VPN thường sử dụng công nghệ IPsec.</li>
 </ul>

<a name="uudiem"></a>
##IV. Những ưu điểm nổi trội của VPN.

- Lợi ích của việc sử dụng VPN (cả remote access và site-to-site) bao gồm :
 <ul>
  <li>Tính tin cậy.</li>
  <li>Tính toàn vẹn.</li>
  <li>Chứng thực.</li>
  <li>Chống tấn công lặp lại.</li>
 </ul>

<a name="tincay"></a>
###1. Tính tin cậy.

- Tính tin cậy (confidentiality) nghĩa là dữ liệu (được mã hóa) trao đổi giữa 2 bên thì chỉ có 2 bên là có thể đọc được (nghĩa là 
chỉ có 2 bên là có khóa giải mã). Bất cứ ai nghe lén hoặc bắt được dữ liệu đó mà không có khóa giải mã thì cũng vô ích.

<a name="toanven"></a>
###2. Tính toàn vẹn.

- Tính toàn vẹn dữ liệu (data integrity) nghĩa là đảm bảo dữ liệu trao đổi giữa 2 bên được nguyên vẹn, nếu có bất kỳ thay đổi nào 
về dữ liệu trong quá trình truyền đều sẽ bị phát hiện. Chúng ta sử dụng thuật toán hash (băm) để làm việc này.
- Đối với Cisco IOS image, để đảm bảo file image mà ta download từ Cisco là chính xác, không bị lỗi trong quá trình truyền, 
ta có thể dùng lệnh verify với đường dẫn tới file image trong bộ nhớ flash (ví dụ: verify /md5 flash:/c2800nm-advipservicesk9-mz.124-24.T4.bin). 
Kết quả của lệnh này sẽ cho ra một chuỗi MD5 hash, và ta đem so sánh chuỗi hash vừa tính được với chuỗi được cung cấp trên trang web của 
Cisco cho file image này. Nếu giống nhau thì ta biết được rằng file image đã download về là nguyên vẹn, không bị lỗi.

<a name="chungthuc"></a>
###3. Chứng thực.

- Ngoài việc mã hóa dữ liệu và đảm bảo dữ liệu không bị thay đổi trên đường truyền, một VPN tunnel còn phải có khả năng chứng thực (authentication) 
đối tượng ở phía đầu bên kia của VPN tunnel. Có một số cách chứng thực sau:
 <ul>
  <li>Pre-shared key.</li>
  <li>Chữ ký số.</li>
  <li>Username và password (dùng với remote access VPN).</li>
 </ul>

<a name="chongtanconglaplai"></a>
###4. Chống tấn công lặp lại.

- Hầu hết các công nghệ VPN đều hỗ trợ chống kiểu tấn công lặp lại (antireplay), nghĩa là khi một gói tin VPN đã được gửi đi thì gói tin đó sẽ không còn hợp 
lệ khi gửi tiếp lần thứ 2 trong VPN session đó.

<a name="mahoakhoi"></a>
##V. Mã hóa khối.

- Một thuật toán mã hóa khối (block cipher) sẽ thực hiện mã hóa trên một khối bit có kích thước cố định, chẳng hạn lấy 64-bit 
plain text và tạo ra 64-bit cipher text. Các thuật toán mã hóa block cipher là các thuật toán mã hóa đối xứng, nghĩa là key mã 
hóa cũng là key giải mã. Một số thuật toán block cipher bao gồm:
 <ul>
  <li>Advanced Encryption Standard (AES)</li>
  <li>Triple Digital Encryption Standard (3DES)</li>
  <li>Blowfish</li>
  <li>Digital Encryption Standard (DES)</li>
  <li>International Data Encryption Algorithm (IDEA)</li>
 </ul>

- Nếu như không đủ dữ liệu để mã hóa đủ một block thì block cipher sẽ thêm padding vào (chẳng hạn block size là 64 bit nhưng chỉ còn 56 bit 
dữ liệu thì sẽ thêm padding là 8 bit). Điều này có thể dẫn đến overhead (dù rất nhỏ), vì padding sẽ được xử lý chung với dữ liệu thật.

<a name="mahoadoixung"></a>
##VI. Thuật toán mã hóa đối xứng.

- Thuật toán mã hóa đối xứng (symmetric encryption algorithm) là thuật toán sử dụng cùng một key để mã hóa và giải mã dữ liệu. 
Các thuật toán mã hóa đối xứng phổ biến là:
 <ul>
  <li>DES</li>
  <li>3DES</li>
  <li>AES</li>
  <li>IDEA</li>
  <li>RC2, RC4, RC5, RC6</li>
  <li>Blowfish</li>
 </ul>

- Thuật toán mã hóa đối xứng là thuật toán dùng để mã hóa dữ liệu trong các kết nối VPN ngày nay. Lý do dùng thuật toán mã 
hóa đối xứng là vì nó nhanh hơn nhiều và tốn ít CPU hơn so với thuật toán mã hóa bất đối xứng. Vì thuật toán được public nên 
dữ liệu có an toàn hay không phụ thuộc vào chiều dài key. Chiều dài key thông thường là từ 40 bit đến 256 bit, và key càng 
dài thì càng an toàn. Chiều dài key phải ít nhất 80 bit mới được xem là tương đối an toàn.

<a name="mahoabatdoixung"></a>
##VII. Thuật toán mã hóa bất đối xứng.

- Thuật toán mã hóa bất đối xứng (asymmetric encryption algorithm) là thuật toán sử dụng key mã hóa và key giải mã khác nhau. 
2 key này tạo thành một cặp, và được gọi là public key và private key. Public key là key được phép công khai cho mọi người biết, 
còn private key là key được giữ bí mật bởi người sở hữu cặp public-private key đó. Nếu mã hóa bằng public key thì cách duy nhất để 
giải mã là dùng private key, và nếu mã hóa bằng private key thì cách duy nhất để giải mã là dùng public key. Tuy nhiên, thuật toán 
bất đối xứng làm tốn rất nhiều CPU, vì vậy ta không dùng nó để mã hóa và giải mã dữ liệu của user, mà chỉ dùng cho một số mục đích 
như chứng thực VPN peer hoặc phát sinh key để dùng cho thuật toán đối xứng.

<a name="hambam"></a>
##VIII. Hàm băm.

- Băm (hashing) là phương pháp dùng để kiểm tra tính toàn vẹn dữ liệu. Một hàm hash sẽ xử lý một khối dữ liệu và tạo ra một chuỗi dữ 
liệu với kích thước cố định (fixed-length). Hàm hash là hàm một chiều, nghĩa là không thể suy ra khối dữ liệu ban đầu từ chuỗi dữ liệu 
sau khi hash.
 <ul>
  <li>Nếu 2 máy tính khác nhau dùng cùng một hàm hash để xử lý cùng một khối dữ liệu thì chuỗi dữ liệu sau khi hash phải giống nhau.</li>
  <li>Không thể phát sinh cùng một chuỗi hash từ các khối dữ liệu khác nhau.</li>
 </ul>

- Kết quả của hàm hash là một chuỗi dữ liệu với kích thước cố định, và được gọi là digest, message digest, hoặc hash.

- Bên gửi sẽ chạy thuật toán hash cho mỗi gói tin và đính kèm kết quả hash trên mỗi gói tin đó. Nếu bên nhận chạy lại 
thuật toán hash trên gói tin và so sánh kết quả hash thấy giống với kết quả được gửi kèm trong mỗi gói tin thì nghĩa là 
dữ liệu trong gói tin còn nguyên vẹn. Nếu kết quả khác nhau nghĩa là dữ liệu đã bị thay đổi trong quá trình truyền.

- Có 3 loại hash phổ biến là :
 <ul>
  <li>Message digesst 5 (MD5) : Tạo ra 128-bit digest.</li>
  <li>Secure Hash Algorithm 1 (SHA-1): Tạo ra 160-bit digest</li>
  <li>Secure Hash Algorithm 2 (SHA-2): Tạo ra 224-bit hoặc 512-bit digest</li>
 </ul>

- Cũng như mã hóa, đối với hash thì càng nhiều bit đồng nghĩa với càng an toàn. 

<a name="hmac"></a>
##IX. HMAC.

- Hashed Message Authentication Code (HMAC) sử dụng cơ chế hash, nhưng dùng secret key để mã hóa trước rồi mới hash. 
Bằng cách này thì attacker nếu không có secret key sẽ không thể nào thay đổi dữ liệu trong gói tin mà không bị phát hiện. 
HMAC khắc phục nhược điểm của hash thông thường (không dùng secret key).

<a name="chukyso"></a>
##X. Chữ ký số.

- Chữ ký số (digital signature) đem lại 3 lợi ích:
 <ul>
  <li>Chứng thực.</li>
  <li>Tính toàn vẹn.</li>
  <li>Tính không từ chối trách nhiệm (non-repudiation)</li>
 </ul>

<a name="quanlykey"></a>
##XI. Quản lý key.

- Quản lý key (key management) giải quyết các vấn đề liên quan đến tạo key, kiểm tra key, trao đổi key, lưu trữ key, và khi 
hết thời hạn sử dụng thì hủy key.

- Không gian key (keyspace) là tập hợp tất cả các giá trị có thể có của key. Key càng dài (keyspace càng lớn) thì càng an toàn. 
Tuy nhiên, nhược điểm của việc sử dụng key quá dài là sẽ khiến cho thời gian mã hóa và giải mã dữ liệu lâu hơn, và tốn nhiều CPU hơn.

<a name="ipsecvassl"></a>
##XII. Sơ lược về IPSEC và SSL.

<a name="ipsec"></a>
###1. IPSEC.

- IPsec là tập hợp các giao thức và thuật toán dùng để bảo vệ gói tin IP. IPsec mang lại các lợi ích về confidentiality thông qua mã hóa, 
data integrity thông qua hashing và HMAC, và authentication bằng cách sử dụng chữ ký số hoặc pre-shared key (PSK). IPsec cũng hỗ trợ antireplay. 
Dưới đây là các thành phần của IPsec:
 <ul>
  <li>ESP và AH: Đây là 2 phương pháp chính để triển khai IPsec. ESP là viết tắt của Encapsulating Security Payload và có 
  thể thực hiện tất cả các tính năng của IPsec. AH là viết tắt của Authentication Header, có thể thực hiện nhiều tính năng 
  của IPsec ngoại trừ một tính năng quan trọng là mã hóa dữ liệu. Vì lý do đó nên ta ít thấy AH được sử dụng.</li>
  <li>Thuật toán mã hóa: DES, 3DES, AES.</li>
  <li>Thuật toán hash: MD5, SHA.</li>
  <li>Kiểu chứng thực: Pre-shared key, chữ ký số.</li>
  <li>Quản lý key: Thuật toán mã hóa bất đối xứng Diffie-Hellman (DH) dùng để phát sinh key tự động cho các thuật toán mã hóa đối xứng. Internet Key Exchange (IKE) 
  thực hiện các công việc thương lượng và quản lý key.</li>
 </ul>

<a name="ssl"></a>
###2. SSL.

- IPsec có thể dùng cho site-to-site hoặc remote-access VPN, còn SSL chỉ dùng cho remote-access VPN. Tuy nhiên, việc sử dụng 
SSL cho remote-access VPN tỏ ra tiện lợi hơn IPsec, vì hầu như mọi trình duyệt web (web browser) đều hỗ trợ SSL, trong khi 
muốn sử dụng IPsec thì máy tính phải có IPsec client.

- Để sử dụng SSL, user sẽ kết nối đến web server hỗ trợ SSL (SSL server) thông qua giao thức HTTPS. Phụ thuộc vào web server 
kết nối tới mà SSL còn được gọi là Transport Layer Security hay TLS. Tiếp theo, trình duyệt sẽ yêu cầu web server tự định 
danh, và web server sẽ gửi cho trình duyệt chứng chỉ số của nó, hay còn gọi là chứng chỉ SSL (SSL certificate). Khi trình 
duyệt nhận được chứng chỉ số của web server, nó sẽ thực hiện kiểm tra tính hợp lệ của chứng chỉ bằng cách kiểm tra chữ ký 
số của CA trên chứng chỉ đó. Nếu chữ ký số của CA hợp lệ thì trình duyệt sẽ tin tưởng chứng chỉ số của web server và chấp nhận 
public key của web server chứa trong chứng chỉ số đó.

- Thông thường, web server không yêu cầu trình duyệt tự định danh, mà nó sẽ chứng thực user thông qua username và password.

- Sau khi chứng thực xong, trình duyệt và web server sẽ tiếp tục trao đổi và thương lượng về thuật toán mã hóa mà chúng sẽ sử 
dụng và key dùng để mã hóa và giải mã dữ liệu.