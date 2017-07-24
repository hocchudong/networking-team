# NFV - Network Functions Virtualization
# Mục lục
### [1. NFV definition](#def)
### [2. NFV benefits](#benefits)
### [3. NFV Architecture](#arch)
### [4. NFV Usecases](#usecases)
### [5. Thách thức của NFV](#challenges)
### [6. Tham khảo](#ref)
---

## <a name="def"></a>1. NFV definition

### Giới thiệu

Hệ thống mạng viễn thông hiện tại được vận hành sử dụng các thiết bị phần cứng độc quyền của nhiều nhà cung cấp khác nhau. Việc vận hành network service mới đồng nghĩa với việc sử dụng thêm nhiều thiết bị hơn, đòi hỏi phải mở rộng không gian để triển khai, đặt ra vấn đề về việc chi phí năng lượng ngày càng tăng, thách thức về vốn đầu tư, yêu cầu các kỹ năng cần thiết để thiết kế, tích hợp và vận hành các thiết bị mạng vật lý càng ngày càng phức tạp. Ngoài ra vòng đời các thiết bị phần cứng cũng không dài, yêu cầu có kế hoạch về chu kì thiết kế - tích hợp - triển khai phù hợp. Tệ hơn, vòng đời của phần cứng đang ngày một ngắn dần do sự phát triển nhanh chóng của các dịch vụ và công nghệ, gây khó khăn cho việc triển khai các network services mới để thu về lợi nhuận, hạn chế sự đổi mới bởi vì xu hướng hiện tại là hướng về các giải pháp mạng lưới tập trung.

### Definition
Network Functions Virtualization (NFV) mang đến cách thức mới để thiết kế, triển khai và quản lý các dịch vụ mạng, sử dụng các công nghệ ảo hóa tiêu chuẩn hiện tại để hợp nhất nhiều loại thiết bị mạng trên các __high volume servers, switches và storages__ theo tiêu chuẩn công nghiệp được đặt trong các Datacenter, các Network node và tại nhà của người dùng cuối. 

NFV tách biệt các __network functions__ (NAT, firewalling, intrusion detection, DNS, caching) khỏi các thiết bị vật lý và triển khai dưới hình thức phần mềm và có thể chạy trên các server vật lý truyền thống, đồng thời có thể di trú hoặc được khởi tạo trên nhiều vị trí trong hệ thống mạng theo yêu cầu mà không cần phải triển khai thiết bị mới như trước đây.

![topo](http://i.imgur.com/YkhoIVq.png)

### Lịch sử của NFV
Định nghĩa về NFV bắt nguồn từ các nhà cung cấp dịch vụ - những người đang tìm kiếm giải phát để thúc đẩy nhanh hơn việc triển khai các dịch vụ mạng mới, thu về lợi nhuận. Những hạn chế của các thiết bị phần cứng đòi hỏi họ phải áp dụng các công nghệ ảo hóa vào hệ thống mạng của họ. Vì chung mục đích như vậy, nhiều nhà cung cấp dịch vụ đã hợp tác với nhau và thành lập nên ETSI (European Telecommunications Standards Institute - 1988). Trong đó ETSI ISG NFV (ETSI Industry Specification Group for Network Functions Virtualization), là nhóm có nhiệm vụ phát triển các yêu cầu và kiến trúc để áp dụng ảo hóa cho nhiều chức năng trong hệ thống mạng viễn thông. ETSI ISG NFV vận hành từ tháng 1 năm 2013, mang 7 nhà mạng viễn thông hàng đầu đến với nhau:  AT&T, BT, Deutsche Telekom, Orange, Telecom Italia, Telefonica, và Verizon. Ngoài ra còn có sự tham gia của 52 nhà mạng, các nhà cung cấp thiết bị viễn thông, IT vendors khác. Không lâu sau đó, cộng đồng ETSI ISG NFV mở rộng với 230 công ty, bao gồm nhiều nhà cung cấp dịch vụ toàn cầu.

## <a name="benefits"></a>2. Lợi ích của NFV

- Giảm phi phí vốn (CAPEX - Capital expenditures) đặc biệt là với NFVI (NFV Infrastructure):
    - Việc sử dụng COTS (commercial off-the-shelf) hardware và COTS servers giảm chi phí về phần cứng. Có rất nhiều nhà cung cấp có thể cung cấp các servers như vậy, làm tăng cạnh tranh trên thị trường, từ đó giúp cắt giảm chi phí.
    - Nhờ việc cung cấp dịch vụ dưới hình thức phần mềm, các tổ chức không cần phải quan tâm nhiều tới các phần cứng đặc biệt để chạy các chức năng mạng nữa. Điều đó cũng có nghĩa là chi phí bảo hành của các nhà cung cấp phần cứng độc quyền không còn được áp dụng.
    - Một servers thông thường có thể được sử dụng để xây dựng nhằm mục đích dự phòng và sẵn sàng đáp ứng yêu cầu trong môi trường datacenter của một tổ chức. Điều đó giúp cho các tổ chức, doanh nghiệp không cần phải mua và duy trì các thiết bị đắt tiền để dự phòng; và trong trường hợp gặp trục trặc, hạ tầng ảo hóa có khả năng chia sẻ hoặc hạ tầng cloud có thể di trú workload để đảm bảo hệ thống hoạt động liên tục và đảm bảo hiệu suất.
    - NFV có khả năng sử dụng hạ tầng chia sẻ từ nhiều nhà cung cấp dịch vụ cloud để chạy các chức năng mạng theo yêu cầu bởi một tổ chức. Bằng cách đi thuê thay vì mua các thiết bị hoàn toàn, tổ chức có thể tận dụng lợi thế của mô hình pay-as-you-grow, tránh tốn kém và lãng phí để trích lập dự phòng.
    - Do sử dụng phần cứng thương mại ít đắt tiền, doanh nghiệp có thể nâng cấp phần cứng thường xuyên hơn, giảm vòng đời sử dụng   phần cứng để tăng hiệu năng tổng thể của hệ thống mạng, giải quyết hiệu quả những yêu cầu ngày càng thay đổi đối với hệ thống mạng của họ và tăng giá trị thu được trong suốt vòng đời của các máy chủ này.

- Giảm chi phí vận hành (OPEX - Operational expenditure) đối với cả NFVI (NFV Infrastructure) và NFV MANO (MFV Management and Orchestration).
    - Service functions dưới dạng software cho phép các tổ chức di trú và mở rộng các chức năng mạng nhanh chóng, dễ dàng để giải quyết các thay đổi về yêu cầu, tối đa hóa khả năng sử dụng của các phần cứng thương mại. Một server đơn lẻ có thể sử dụng để cung cấp nhiều tính năng khác nhau, giảm thiểu yêu cầu khi triển khai, quản lý và bảo trì các loại phần cứng chuyên biệt với các chức năng chuyên biệt.
    - Với việc sử dụng phần cứng hiệu quả hơn, các tổ chức có thể tái sử dụng không gian, chi phí điện năng và làm mát đối với hệ thống họ triển khai. Phần cứng tiêu chuẩn thường tận dụng được các kỹ thuật một cách hoàn thiện trong hệ thống datacenter cỡ lớn của nhà cung cấp dịch vụ cloud, ví dụ như Facebook hoặc Google, để phục vụ các thao tác vận hành phức tạp hơn.
    - Các thủ tục vận hành và tự động hóa nói chung được sử dụng bởi phần cứng thương mại làm đơn giản hóa việc quản lý và triển khai. Các phần cứng tiêu chuẩn cũng như các phần mềm tiêu chuẩn như các hệ thống điều phối và các hypervisors, thường sử dụng các platform và script tự động mang lại khả năng quản lý hiệu quả với tỷ lệ trung bình từ 1:10/1:100 tới 1:1000.
    - Về mặt tổng thể, các chức năng ảo hóa có tính linh hoạt cao hơn và ít phức tạp hơn khi quản lý; tổ chức có thể nhanh chóng và dễ dàng tạo các template để triển khai, từ đó tiến trình di trú và tái triển khai các chức năng sẽ đơn giản hơn.

- Tăng tốc độ đưa dịch vụ mới vào thương mại
    - Các chức năng ảo hóa có thể dễ dàng cài đặt và dự phòng cho phép tổ chức nhanh chóng triển khai dịch vụ bất cứ khi nào và bất kì nơi nào họ cần.
    - Các chức năng ảo hóa cho phép các tổ chức thử các dịch vụ mới mà không phải chịu quá nhiều rủi ro. Các framework tiêu chuẩn và khả năng khôi phục linh động khi gặp trục trặc được sử dụng bởi một framework chịu trách nhiệm điều phối, cho phép tổ chức giảm thiểu đáng kể rủi ro để triển khai sản phẩm mới từ nhà cung cấp. Chi phí thấp và sự linh hoạt trong việc di trú và mở rộng các chức năng khi cần thiết giúp thúc đẩy việc đổi mới dịch vụ. POCs và các bản thử nghiệm có thể chạy nhanh hơn, trong môi trường quy mô nhỏ hơn.
    - Khả năng chạy các dịch vụ ảo hóa trên nền hệ thống mạng vật lý bên dưới cho phép tổ chức không cần thiết phải tốn thời gian hay chi phí nâng cấp hệ thống hiện tại của họ để cung cấp dịch vụ mới.

- Cung cấp nhanh chóng và linh hoạt
    - Do tổ chức không phải chịu khấu hao chi phí cho thiết bị đắt tiền hoặc xử lý vốn thiết bị mua lại (tại nơi mà họ cần hàng triệu đô để nâng cấp hoặc triển khai dịch vụ mới cho khách hàng đơn lẻ), họ có thể nhanh chóng và dễ dàng giải quyết yêu cầu của khách hàng. Giờ đây họ có thể dự phòng bằng một cặp server để cung cấp dịch vụ sử dụng ngắn hạn hoặc sử dụng một lần.
    - Khả năng dễ dàng xóa bỏ, di trú và mở rộng và cấu hình các dịch vụ theo yêu cầu khách hàng hoặc yêu cầu kinh doanh thay đổi mang lại cho tổ chức khả năng cung cấp dịch vụ ở bất kỳ đâu trên thế giới và ở bất kỳ thời điểm nào.

Những khả năng này của NFV đã được các chuyên gia trong ngành viễn thông cũng như những triển khai hiện có xác nhận, thông qua các cuộc khảo sát đối với các triển khai thực tế từ các nhà cung cấp dịch vụ toàn cầu như AT&T, Telefonica, Telstra, SK Telecom, Swisscom, Vodacom. Năm 2016 chứng kiến sự di chuyển từ PoCs sang các bản thử nghiệm NFV trên môi trường thương mại. Khảo sát từ nhiều nhà cung cấp dịch vụ cho kết quả như sau.

![report](https://www.sdxcentral.com/wp-content/uploads/2016/03/NFV-Business-Use-Case-NFV-Drivers.png)

## <a name="arch"></a>3. Kiến trúc NFV
### High level Architecture
- Kiến trúc NFV ở mức high level gồm 3 miền làm việc chính:

    - VNF - Virtualised Network Functions: là các chức năng mạng hay thiết bị mạng ảo triển khai dưới dạng phần mềm trên hạ tầng NFV
    - NFVI - NFV Infrastructure: bao gồm các tài nguyên vật lý và công nghệ ảo hóa hỗ trợ để cung cấp tài nguyên triển khai VNF.
    - NFV Management and Orchestration: thực hiện điều phối, quản lý vòng đời các tài nguyên phần cứng và tài nguyên phần mềm hỗ trợ hạ tầng ảo hóa, quản lý vòng đời các VNFs. 

    ![hlv](https://www.sdxcentral.com/wp-content/uploads/2015/04/nfv-report-2015-high-level-nfv-framework.png)

- NFV framework cho phép xây dựng, quản lý các VNFs instance và mối liên hệ giữa các VNFs về mặt dữ liệu, kiểm soát, quản lý, các gói phụ thuộc và các thuộc tính khác. Có nhiều góc nhìn khác nhau đối với các VNFs để từ đó nảy sinh ra các usecase khác nhau, điển hình là hai use case:

    - VNF Forwarding Graph (VNF-FG hay Service Chaining): đặc tả kết nối mạng giữa các VNFs (firewall, NAT, load balancer, etc.) tạo thành chuỗi các dịch vụ (Service Chain)
    - Virtualisation of the Home Environment.


### NFV Reference Architectural Framework

![arch-fr](http://i.imgur.com/xQKq5GD.png)

Các khối chức năng:
- Virtualised Network Function (VNF): là các chức năng mạng ảo hóa như: NAT, DHCP, firewall, load balancer, PGW (Packet Data Network Gateway), Serving Gateway (SGW), Mobility Management Entity (MME), etc. Các VNF có thể triển khai trong 1 VM hoặc cũng có thể là sự kết hợp của nhiều VM tùy vào loại dịch vụ mạng mà VNF cung cấp và cách triển khai.

- Element Management System (EMS): quản lý việc vận hành của VNF, giống như hệ thống EMS quản lý cho các thành phần network vật lý, EMS quản lý sự cố và hiệu năng của VNF. EMS làm được điều đó thông qua interface phù hợp. Một EMS có thể quản lý cho 1 VNF hoặc nhiều VNF. Tự thân EMS cũng có thể là một VNF.

- NFV Infrastructure, bao gồm:
    - Tài nguyên vật lý và tài nguyên ảo hóa: các tài nguyên vật lý bao gồm các tài nguyên tính toán, lưu trữ và network cung cấp chức năng xử lý, lưu trữ và kết nối tới các VNF thông qua lớp ảo hóa hypervisors. Tài nguyên tính toán vật lý là Commercial off-the-shelf.
    - Lớp ảo hóa

- Virtualised Infrastructure Manager(s): thống kê, giám sát tài nguyên trên hạ tầng NFV; quản lý và cấp phát tài nguyên cho các VNF.
    - NFV Orchestrator chịu trách nhiệm tạo, bảo trì và xóa bỏ các network services. Nếu có nhiều VNFs, orchestrator sẽ kích hoạt việc khởi tạo E2E service thông qua nhiều VNFs. NFVO cũng chịu trách nhiệm quản lý tài nguyên của NFVI (các tài nguyên compute, storage, networking giữa nhiều VIMs trong mạng). Orchestrator thực hiện các chức năng của nó gián tiếp qua VNFM và VIM chứ không trực tiếp tới từng VNFs.

        Ví dụ: nhiều VNFs cần phải xâu lại với nhau để tạo E2E service, ví dụ như virtual Base station và virtual EPC. Khi đó NFVO sẽ nói chuyện với các VNFs để tạo E2E network theo yêu cầu. 

    - VNF Manager(s) quản lý một hoặc nhiều VNF(s), cụ thể là quản lý vòng đời các VNF instances. Quản lý vòng đời ở đây bao gồm việc cài đặt, bảo trì và hủy bỏ VNFs. Một VNF manager có thể thực hiện cùng chức năng với EMS nhưng thông qua giao diện phù hợp với interface/reference point trong kiến trúc NFV (Ve-Vnfm).            

    - Operations and Business Support Systems (OSS/BSS): công cụ của nhà cung cấp dịch vụ mạng viễn thông (operator), hỗ trợ trong việc quản lý vận hành hệ thống mạng (OSS) cũng như trong việc quản lý khách hàng, kinh doanh, tính cước (BSS). Với sự phát triển của mạng viễn thông (ngày càng phức tạp, nhiều dịch vụ, nhiều thiết bị,...), OSS/BSS trở thành một công cụ không thể thiếu của các operators giúp họ quản lý vận hành mạng một cách hiệu quả hơn.

## <a name="usecases"></a>4. NFV Usecases
### Network Functions Virtualisation Infrastructure as a Service
Hạ tầng NFV được xây dựng dựa trên công nghệ Cloud Computing. Các nhà cung cấp dịch vụ (Service Providers - SPs) do đó chạy các VNF instances trên hạ tầng NFV Cloud-based đó. Một số SPs có đủ tài nguyên để triển khai và duy trì hạ tầng vật lý ở quy mô toàn cầu, khách hàng có thể yêu cầu dịch vụ theo yêu cầu ở bất kỳ đâu trên thế giới. Tuy nhiên, khả năng triển khai từ xa và chạy các VNFs trên hạ tầng NFV cung cấp như một dịch vụ bởi một SPs khác sẽ là hiệu quả hơn khi cung cấp dịch vụ cho khách hàng toàn cầu. Khả năng một SP cung cấp hạ tầng NFV của họ cho SP(s) khác cho phép kích hoạt thêm một dịch vụ thương mại để cung cấp hỗ trợ trực tiếp và đẩy nhanh việc triển khai hạ tầng NFV. Hạ tầng NFV cũng có thể được cung cấp từ cơ sở này sang cơ sở khác trong nội bộ một SP.

![nfviaas](http://i.imgur.com/OVG7ynP.png)

### Virtual Network Function as a Service (VNFaaS)</h3>
Hệ thống mạng các doanh nghiệp hiện đang triển khai các dịch vụ sử dụng một thiết bị vật lý phục vụ cho mỗi tính năng, gặp vấn đề về sự thiếu linh hoạt, cài đặt và bảo trì chậm, khó khăn. Các chức năng có thể cung cấp trong một access router tích hợp nhưng hạn chế về tính năng. Do đó khi doanh nghiệp phát triển, đòi hỏi nhiều dịch vụ hơn thì họ di trú dịch vụ và ứng dụng lên datacenter hoặc public cloud. Ngoài ra, xu hướng mobility và BYOD (Bring your own device) là hệ quả tất yếu dẫn tới yêu cầu các dịch vụ như ngăn chặn rò rỉ dữ liệu.

*__BYOD - bring your own device:__ là xu hướng các công ty khuyến khích nhân viên của họ sử dụng thiết bị cá nhân như smartphone, tablet để truy cập dịch vụ hay dữ liệu của công ty, điều đó nảy sinh ra vấn đề về bảo mật và nguy cơ bị đánh cắp thông tin.*

Giải pháp cho vấn đề trên là đưa các Access Router ảo vCPE vào trong mạng của nhà vận hành, triển khai dưới dạng dịch vụ chạy trên các máy ảo hay VNF (Virtualize Network Functions) instance trên hạ tầng NFV (sử dụng công nghệ cloud computing). Nhờ vậy, khi cần cung cấp thêm các tính năng networking nâng cao như `measured service`, các dịch vụ này sẽ được đáp ứng nhanh chóng và quan trọng là doanh nghiệp không phải tốn thêm chi phí vận hành mua các thiết bị vật lý mới như trước đây để triển khai các dịch vụ đó. Giờ đây họ chỉ phải trả chi phí cơ bản cho nhà cung cấp để họ cung cấp thêm dịch vụ, hoặc mở rộng tài nguyên trên hạ tầng NFV để cấp phát thêm tài nguyên cho các VNF instance đáp ứng nhu cầu sử dụng tăng lên của các VNF.

![nfviaas-sth](http://i.imgur.com/sAyWTUQ.png)

![nfviaas-sth1](http://i.imgur.com/lcDF1XV.png)

### Service Chains (VNF Forwarding Graphs)
Network Function Forwarding Graph (NFFG) định nghĩa một tập hợp có trình tự các Network Functions mà packet phải đi qua, tạo thành Network Service. VNFFGs tương tự như vậy, tuy nhiên nó là sự kết nối về mặt logic giữa các thiết bị mạng ảo triển khai trong các VNF (Virtualized Network Functions), ngoài ra cũng có thể kết nối nội bộ với các Physical Network Functions để cung cấp Network services.

- Logical View:

![logical-view](http://i.imgur.com/9oeLxpf.png)

- Service Chaining - VNFFG scenario:

    - __INTRA-DATACENTER SERVICE CHAINING__:

    ![intra](http://www.sdnspace.com/Portals/0/LiveBlog/983/fig1_thumb.png)

    - __INTER-DATACENTER SERVICE CHAINING__:

    ![inter](http://i.imgur.com/wsIYRkT.png)

### Virtualisation of the Home Environment
- Các nhà cung cấp dịch vụ cung cấp dịch vụ gia đình sử dụng hệ thống network và CPE (customer premises equipments) đặt tại hộ gia đình. Các thiết bị CPE này nhận biết nhà cung cấp và nhà cung cấp dịch vụ bằng cách sử dụng RGW (Residential Gateway) cho dịch vụ Internet và VOIP, Set-top box với dịch vụ đa phương tiện. 

- Ứng dụng NFV để ảo hóa môi trường cung cấp dịch vụ gia đình có nhiều ưu điểm:
    - Giảm chi phí về STB và RGW

    - Giảm chi phí duy trì và nâng cấp CPEs

    - Cải thiện chất lượng trải nghiệm dịch vụ (QoE) như điều khiển truy cập tới tất cả cá nội dung và dịch vụ, hỗ trợ multi-screen và di động.

    - Cung cấp dịch vụ mới nhanh chóng và tiện lợi, giảm bớt sự rườm rà vì phụ thuộc chức năng của CPE cũng như tiến trình cài đặt cũng được đơn giản hóa.

-  Với mạng truyền thống không sử dụng ảo hóa, mỗi gia đình sẽ sử dụng một RGW và một IP STB. Tất cả các dịch vụ được nhận từ RGW, chuyển đổi sang địa chỉ private IP và cung cấp vào hộ gia đình đó. RGW kết nối (thông qua PPPoE Tunnel hoặc IPoE) tới BNG để kết nối tới Internet hoặc DC. 

![vhe](http://i.imgur.com/6hHDN42.png)

- Với hạ tầng ảo hóa NFV, các dịch vụ và chức năng di trú từ thiết bị tại nhà lên NFV cloud, các thiết bị như RGW và STB được triển khai trong các VNF instance và trở thành vRGW và vSTB.

![nfv](http://i.imgur.com/u0LkmH3.png)

### Virtual Network Platform as a Service (VNPaaS
### Virtualisation of Mobile Core Network and IMS
### Virtualisation of Mobile base station
### Virtualisation of CDNs (vCDN)
### Fixed Access Network Functions Virtualisation

## <a name="challenges"></a>5. Thách thức của NFV
- __Portability/Interoperabiliby__: Các thiết bị mạng ảo phải có tính di động đối với nhiều loại phần cứng của các nhà cung cấp khác nhau, và tương thích với nhiều loại hypervisors. 

- __Performance Trade-Off__: Các chức năng mạng ảo hiệu năng không thể đạt được hiệu năng như các thiết bị phần cứng, do đó thách thức là tối thiểu hóa latency, throughput và quá tải khi xử lý dữ liệu bằng việc sử dụng hypervisors phù hợp và các công nghệ phần mềm hiện đại.
- __Migration and co-existence of legacy & compatibility with existing platforms__: NFV phải làm việc trong môi trường hybrid network bao gồm các thiết bị mạng vật lý truyền thống cũng như các thiết bị mạng ảo. Các thiết bị mạng ảo do đó cũng phải sử dụng North Bound Interfaces (phục vụ yêu cầu quản lý và kiểm soát) và trao đổi dữ liệu với các thiết bị vật lý triển khai cùng chức năng.
- __Management and Orchestration__: NFV infrastructure cần khởi tạo VNFs ở vị trí phù hợp ở thời điểm phù hợp, cấp phát và mở rộng tài nguyên phần cứng một cách linh động cho các VNFs đó và kết nối chúng tạo ra service chaining. Tính linh hoạt trong việc dự phòng dịch vụ đặt ra yêu cầu quản lý được cả thiết bị phần cứng và phần mềm.

- __Automation__: Network Functions Virtualization chỉ có thể mở rộng phạm vi nếu như các chức năng mạng có thể tự động hóa.
- __Security & Resilience__: Các thiết bị mạng ảo phải có khả năng tái tạo theo yêu cầu sau khi gặp sự cố, đảm bảo tính bảo mật tương tự như thiết bị vật lý, đặc biệt hypervisor và cấu hình của VNF phải đảm bảo bảo mật. Người vận hành mạng phải sử dụng các công cụ để kiểm soát và kiểm chứng cấu hình của hypervisors để đảm bảo tính an toàn của hypervisors và thiết bị ảo hóa.
- __Network Stability__: Đảm bảo tính ổn định chỉ quan trọng trong một số trường hợp, ví dụ khi VFs tái thay đổi vị trí hoặc trong trường hợp tái cấu hình lại VFs(do sự cố về phần cứng hoặc phần mềm), hoặc khi bị tấn công mạng. Thách thức này không chỉ riêng đối với NFV mà là thách thức với cả hệ thống mạng hiện tại.
- __Integration__: Người vận hành mạng cần phải "mix & match" phần cứng, hypervisors và các thiết bị mạng ảo từ nhiều nhà cung cấp khác nhau mà không gây phát sinh quá nhiều chi phí để tích hợp cũng như tránh lock-in, phụ thuộc vào nhà cung cấp.

## <a name="ref"></a>6. Tham khảo
- [1] - <a href="https://www.sdxcentral.com/nfv/definitions/whats-network-functions-virtualization-nfv/">https://www.sdxcentral.com/nfv/definitions/whats-network-functions-virtualization-nfv/</a>

- [2] - <a href="https://www.sdxcentral.com/nfv/definitions/etsi-isg-nfv/">https://www.sdxcentral.com/nfv/definitions/etsi-isg-nfv/</a>

- [3] - <a href="https://www.sdxcentral.com/reports/nfv-mano-nfvi-2016/chapter-1-investment-benefits-of-nfv/">https://www.sdxcentral.com/reports/nfv-mano-nfvi-2016/chapter-1-investment-benefits-of-nfv/</a>

- [4] - <a href="https://pdfs.semanticscholar.org/99d4/73437ea95dddc983a197e96569505be757f2.pdf">https://pdfs.semanticscholar.org/99d4/73437ea95dddc983a197e96569505be757f2.pdf</a>
