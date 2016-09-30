# NFV - Network Functions Virtualization
# Mục lục
<h3><a href="#def">1. NFV definition</a></h3>
<h3><a href="#benefits">2. NFV benefits</a></h3>
<h3><a href="#arch">3. NFV Architecture</a></h3>
<h3><a href="#usecases">4. NFV Usecases</a></h3>
<h3><a href="#challenes">5. Thách thức của NFV</a></h3>
<h3><a href="#ref">6. Tham khảo</a></h3>

---

<h2><a name="def">1. NFV definition</a></h2>
<div>
    <h3>Giới thiệu</h3>
    <div>        
        Hệ thống mạng viễn thông hiện tại được vận hành sử dụng các thiết bị phần cứng độc quyền của nhiều nhà cung cấp khác nhau. Việc vận hành network service mới đồng nghĩa với việc sử dụng thêm nhiều thiết bị hơn, đòi hỏi phải mở rộng không gian để triển khai, đặt ra vấn đề về việc chi phí năng lượng ngày càng tăng, thách thức về vốn đầu tư, yêu cầu các kỹ năng cần thiết để thiết kế, tích hợp và vận hành các thiết bị mạng vật lý càng ngày càng phức tạp. Ngoài ra vòng đời các thiết bị phần cứng cũng không dài, yêu cầu có kế hoạch về chu kì thiết kế - tích hợp - triển khai phù hợp. Tệ hơn, vòng đời của phần cứng đang ngày một ngắn dần do sự phát triển nhanh chóng của các dịch vụ và công nghệ, gây khó khăn cho việc triển khai các network services mới để thu về lợi nhuận, hạn chế sự đổi mới bởi vì xu hướng hiện tại là hướng về các giải pháp mạng lưới tập trung.
    </div>
    <h3>Definition</h3>
    <div>
        Network Functions Virtualization (NFV) mang đến cách thức mới để thiết kế, triển khai và quản lý các dịch vụ mạng, sử dụng các công nghệ ảo hóa tiêu chuẩn hiện tại để hợp nhất nhiều loại thiết bị mạng trên các <b>high volume servers, switches và storages</b> theo tiêu chuẩn công nghiệp được đặt trong các Datacenter, các Network node và tại nhà của người dùng cuối. 
        <br>
        NFV tách biệt các <b>network functions</b> (NAT, firewalling, intrusion detection, DNS, caching) khỏi các thiết bị vật lý và triển khai dưới hình thức phần mềm và có thể chạy trên các server vật lý truyền thống, đồng thời có thể di trú hoặc được khởi tạo trên nhiều vị trí trong hệ thống mạng theo yêu cầu mà không cần phải triển khai thiết bị mới như trước đây.
        <br><br>
        <img src="http://i.imgur.com/YkhoIVq.png">
        <br><br>
    </div>
    <h3>Lịch sử của NFV</h3>
    <div>
        Định nghĩa về NFV bắt nguồn từ các nhà cung cấp dịch vụ - những người đang tìm kiếm giải phát để thúc đẩy nhanh hơn việc triển khai các dịch vụ mạng mới, thu về lợi nhuận. Những hạn chế của các thiết bị phần cứng đòi hỏi họ phải áp dụng các công nghệ ảo hóa vào hệ thống mạng của họ. Vì chung mục đích như vậy, nhiều nhà cung cấp dịch vụ đã hợp tác với nhau và thành lập nên ETSI (European Telecommunications Standards Institute - 1988). Trong đó ETSI ISG NFV (ETSI Industry Specification Group for Network Functions Virtualization), là nhóm có nhiệm vụ phát triển các yêu cầu và kiến trúc để áp dụng ảo hóa cho nhiều chức năng trong hệ thống mạng viễn thông. ETSI ISG NFV vận hành từ tháng 1 năm 2013, mang 7 nhà mạng viễn thông hàng đầu đến với nhau:  AT&T, BT, Deutsche Telekom, Orange, Telecom Italia, Telefonica, và Verizon. Ngoài ra còn có sự tham gia của 52 nhà mạng, các nhà cung cấp thiết bị viễn thông, IT vendors khác. Không lâu sau đó, cộng đồng ETSI ISG NFV mở rộng với 230 công ty, bao gồm nhiều nhà cung cấp dịch vụ toàn cầu.
    </div>
</div>

<h2><a name="benefits">2. Lợi ích của NFV</a></h2>
<div>
    <ul>
        <li>Giảm phi phí vốn (CAPEX - Capital expenditures) đặc biệt là với NFVI (NFV Infrastructure):
            <ul>
                <li>Việc sử dụng COTS (commercial off-the-shelf) hardware và COTS servers giảm chi phí về phần cứng. Có rất nhiều nhà cung cấp có thể cung cấp các servers như vậy, làm tăng cạnh tranh trên thị trường, từ đó giúp cắt giảm chi phí.</li>
                <li>Nhờ việc cung cấp dịch vụ dưới hình thức phần mềm, các tổ chức không cần phải quan tâm nhiều tới các phần cứng đặc biệt để chạy các chức năng mạng nữa. Điều đó cũng có nghĩa là chi phí bảo hành của các nhà cung cấp phần cứng độc quyền không còn được áp dụng.</li>
                <li>Một servers thông thường có thể được sử dụng để xây dựng nhằm mục đích dự phòng và sẵn sàng đáp ứng yêu cầu trong môi trường datacenter của một tổ chức. Điều đó giúp cho các tổ chức, doanh nghiệp không cần phải mua và duy trì các thiết bị đắt tiền để dự phòng; và trong trường hợp gặp trục trặc, hạ tầng ảo hóa có khả năng chia sẻ hoặc hạ tầng cloud có thể di trú workload để đảm bảo hệ thống hoạt động liên tục và đảm bảo hiệu suất.</li>
                <li>NFV có khả năng sử dụng hạ tầng chia sẻ từ nhiều nhà cung cấp dịch vụ cloud để chạy các chức năng mạng theo yêu cầu bởi một tổ chức. Bằng cách đi thuê thay vì mua các thiết bị hoàn toàn, tổ chức có thể tận dụng lợi thế của mô hình pay-as-you-grow, tránh tốn kém và lãng phí để trích lập dự phòng.</li>
                <li>Do sử dụng phần cứng thương mại ít đắt tiền, doanh nghiệp có thể nâng cấp phần cứng thường xuyên hơn, giảm vòng đời sử dụng phần cứng để tăng hiệu năng tổng thể của hệ thống mạng, giải quyết hiệu quả những yêu cầu ngày càng thay đổi đối với hệ thống mạng của họ và tăng giá trị thu được trong suốt vòng đời của các máy chủ này.</li>
            </ul>
        </li>

        <li>Giảm chi phí vận hành (OPEX - Operational expenditure) đối với cả NFVI (NFV Infrastructure) và NFV MANO (MFV Management and Orchestration).
            <ul>
                <li>Service functions dưới dạng software cho phép các tổ chức di trú và mở rộng các chức năng mạng nhanh chóng, dễ dàng để giải quyết các thay đổi về yêu cầu, tối đa hóa khả năng sử dụng của các phần cứng thương mại. Một server đơn lẻ có thể sử dụng để cung cấp nhiều tính năng khác nhau, giảm thiểu yêu cầu khi triển khai, quản lý và bảo trì các loại phần cứng chuyên biệt với các chức năng chuyên biệt.</li>
                <li>Với việc sử dụng phần cứng hiệu quả hơn, các tổ chức có thể tái sử dụng không gian, chi phí điện năng và làm mát đối với hệ thống họ triển khai. Phần cứng tiêu chuẩn thường tận dụng được các kỹ thuật một cách hoàn thiện trong hệ thống datacenter cỡ lớn của nhà cung cấp dịch vụ cloud, ví dụ như Facebook hoặc Google, để phục vụ các thao tác vận hành phức tạp hơn.</li>
                <li>Các thủ tục vận hành và tự động hóa nói chung được sử dụng bởi phần cứng thương mại làm đơn giản hóa việc quản lý và triển khai. Các phần cứng tiêu chuẩn cũng như các phần mềm tiêu chuẩn như các hệ thống điều phối và các hypervisors, thường sử dụng các platform và script tự động mang lại khả năng quản lý hiệu quả với tỷ lệ trung bình từ 1:10/1:100 tới 1:1000.</li>
                <li>Về mặt tổng thể, các chức năng ảo hóa có tính linh hoạt cao hơn và ít phức tạp hơn khi quản lý; tổ chức có thể nhanh chóng và dễ dàng tạo các template để triển khai, từ đó tiến trình di trú và tái triển khai các chức năng sẽ đơn giản hơn.</li>
            </ul>
        </li>

        <li>Tăng tốc độ đưa dịch vụ mới vào thương mại
            <ul>
                <li>Các chức năng ảo hóa có thể dễ dàng cài đặt và dự phòng cho phép tổ chức nhanh chóng triển khai dịch vụ bất cứ khi nào và bất kì nơi nào họ cần.</li>
                <li>Các chức năng ảo hóa cho phép các tổ chức thử các dịch vụ mới mà không phải chịu quá nhiều rủi ro. Các framework tieeuchuaanr và khả năng khôi phục linh động khi gặp trục trặc được sử dụng bởi một framework chịu trách nhiệm điều phối, cho phép tổ chức giảm thiểu đáng kể rủi ro để triển khai sản phẩm mới từ nhà cung cấp. Chi phí thấp và sự linh hoạt trong việc di trú và mở rộng các chức năng khi cần thiết giúp thúc đẩy việc đổi mới dịch vụ. POCs và các bản thử nghiệm có thể chạy nhanh hơn, trong môi trường quy mô nhỏ hơn.</li>
                <li>Khả năng chạy các dịch vụ ảo hóa trên nền hệ thống mạng vật lý bên dưới cho phép tổ chức không cần thiết phải tốn thời gian hay chi phí nâng cấp hệ thống hiện tại của họ để cung cấp dịch vụ mới.</li>
            </ul>
        </li>

        <li>Cung cấp nhanh chóng và linh hoạt
            <ul>
                <li>Do tổ chức không phải chịu khấu hao chi phí cho thiết bị đắt tiền hoặc xử lý vốn thiết bị mua lại (tại nơi mà họ cần hàng triệu đô để nâng cấp hoặc triển khai dịch vụ mới cho khách hàng đơn lẻ), họ có thể nhanh chóng và dễ dàng giải quyết yêu cầu của khách hàng. Giờ đây họ có thể dự phòng bằng một cặp server để cung cấp dịch vụ sử dụng ngắn hạn hoặc sử dụng một lần.</li>
                <li>Khả năng dễ dàng xóa bỏ, di trú và mở rộng và cấu hình các dịch vụ theo yêu cầu khách hàng hoặc yêu cầu kinh doanh thay đổi mang lại cho tổ chức khả năng cung cấp dịch vụ ở bất kỳ đâu trên thế giới và ở bất kỳ thời điểm nào.</li>
            </ul>
        </li>

    </ul>
    Những khả năng này của NFV đã được các chuyên gia trong ngành viễn thông cũng như những triển khai hiện có xác nhận, thông qua các cuộc khảo sát đối với các triển khai thực tế từ các nhà cung cấp dịch vụ toàn cầu như AT&T, Telefonica, Telstra, SK Telecom, Swisscom, Vodacom. Năm 2016 chứng kiến sự di chuyển từ PoCs sang các bản thử nghiệm NFV trên môi trường thương mại. Khảo sát từ nhiều nhà cung cấp dịch vụ cho kết quả như sau.
    <br><br>
    <img src="https://www.sdxcentral.com/wp-content/uploads/2016/03/NFV-Business-Use-Case-NFV-Drivers.png">
    <br><br>
</div>

<h2><a name="arch">3. Kiến trúc NFV</a></h2>
<div>
    
</div>

<h2><a name="usecases">4. NFV Usecases</a></h2>
<div>
    <ul>
        <li><h3>Network Functions Virtualisation Infrastructure as a Service</h3>
        <div>
            Hạ tầng NFV được xây dựng dựa trên công nghệ Cloud Computing. Các nhà cung cấp dịch vụ (Service Providers - SPs) do đó chạy các VNF instances trên hạ tầng NFV Cloud-based đó. Một số SPs có đủ tài nguyên để triển khai và duy trì hạ tầng vật lý ở quy mô toàn cầu, khách hàng có thể yêu cầu dịch vụ theo yêu cầu ở bất kỳ đâu trên thế giới. Tuy nhiên, khả năng triển khai từ xa và chạy các VNFs trên hạ tầng NFV cung cấp như một dịch vụ bởi một SPs khác sẽ là hiệu quả hơn khi cung cấp dịch vụ cho khách hàng toàn cầu. Khả năng một SP cung cấp hạ tầng NFV của họ cho SP(s) khác cho phép kích hoạt thêm một dịch vụ thương mại để cung cấp hỗ trợ trực tiếp và đẩy nhanh việc triển khai hạ tầng NFV. Hạ tầng NFV cũng có thể được cung cấp từ cơ sở này sang cơ sở khác trong nội bộ một SP.
            <br><br>
            <img src="http://i.imgur.com/OVG7ynP.png">
            <br><br>
        </div>
        </li>

        <li><h3>Virtual Network Function as a Service (VNFaaS)</h3>
            
        </li>

        <li><h3>Virtual Network Platform as a Service (VNPaaS)</h3></li>
        <li><h3>Virtualisation of Mobile Core Network and IMS</h3></li>
        <li><h3>Virtualisation of Mobile base station</h3></li>

        <li><h3>Virtualisation of the Home Environment</h3>

        </li>

        <li><h3>Service Chains (VNF Forwarding Graphs)</h3>

        </li>

        <li><h3>Virtualisation of CDNs (vCDN)</h3></li>
        <li><h3>Fixed Access Network Functions Virtualisation</h3></li>
    </ul>
</div>

<h2><a name="challenes">5. Thách thức của NFV</a></h2>
<div>
    <ul>
        <li><b>Portability/Interoperabiliby</b>: Các thiết bị mạng ảo phải có tính di động đối với nhiều loại phần cứng của các nhà cung cấp khác nhau, và tương thích với nhiều loại hypervisors. 
        </li>
        <li><b>Performance Trade-Off</b>: Các chức năng mạng ảo hiệu năng không thể đạt được hiệu năng như các thiết bị phần cứng, do đó thách thức là tối thiểu hóa latency, throughput và quá tải khi xử lý dữ liệu bằng việc sử dụng hypervisors phù hợp và các công nghệ phần mềm hiện đại.</li>
        <li><b>Migration and co-existence of legacy & compatibility with existing platforms</b>: NFV phải làm việc trong môi trường hybrid network bao gồm các thiết bị mạng vật lý truyền thống cũng như các thiết bị mạng ảo. Các thiết bị mạng ảo do đó cũng phải sử dụng North Bound Interfaces (phục vụ yêu cầu quản lý và kiểm soát) và trao đổi dữ liệu với các thiết bị vật lý triển khai cùng chức năng.</li>
        <li><b>Management and Orchestration</b>: NFV infrastructure cần khởi tạo VNFs ở vị trí phù hợp ở thời điểm phù hợp, cấp phát và mở rộng tài nguyên phần cứng một cách linh động cho các VNFs đó và kết nối chúng tạo ra service chaining. Tính linh hoạt trong việc dự phòng dịch vụ đặt ra yêu cầu quản lý được cả thiết bị phần cứng và phần mềm.
        </li>
        <li><b>Automation</b>: Network Functions Virtualization chỉ có thể mở rộng phạm vi nếu như các chức năng mạng có thể tự động hóa.</li>
        <li><b>Security & Resilience: </b>Các thiết bị mạng ảo phải có khả năng tái tạo theo yêu cầu sau khi gặp sự cố, đảm bảo tính bảo mật tương tự như thiết bị vật lý, đặc biệt hypervisor và cấu hình của VNF phải đảm bảo bảo mật. Người vận hành mạng phải sử dụng các công cụ để kiểm soát và kiểm chứng cấu hình của hypervisors để đảm bảo tính an toàn của hypervisors và thiết bị ảo hóa.</li>
        <li><b>Network Stability: </b>Đảm bảo tính ổn định chỉ quan trọng trong một số trường hợp, ví dụ khi VFs tái thay đổi vị trí hoặc trong trường hợp tái cấu hình lại VFs(do sự cố về phần cứng hoặc phần mềm), hoặc khi bị tấn công mạng. Thách thức này không chỉ riêng đối với NFV mà là thách thức với cả hệ thống mạng hiện tại.</li>
        <li><b>Integration: </b>Người vận hành mạng cần phải "mix & match" phần cứng, hypervisors và các thiết bị mạng ảo từ nhiều nhà cung cấp khác nhau mà không gây phát sinh quá nhiều chi phí để tích hợp cũng như tránh lock-in, phụ thuộc vào nhà cung cấp.</li>
    </ul>
</div>

<h2><a name="ref">6. Tham khảo</a></h2>
<div>
[1] - <a href="https://www.sdxcentral.com/nfv/definitions/whats-network-functions-virtualization-nfv/">https://www.sdxcentral.com/nfv/definitions/whats-network-functions-virtualization-nfv/</a>
<br>
[2] - <a href="https://www.sdxcentral.com/nfv/definitions/etsi-isg-nfv/">https://www.sdxcentral.com/nfv/definitions/etsi-isg-nfv/</a>
<br>
[3] - <a href="https://www.sdxcentral.com/reports/nfv-mano-nfvi-2016/chapter-1-investment-benefits-of-nfv/">https://www.sdxcentral.com/reports/nfv-mano-nfvi-2016/chapter-1-investment-benefits-of-nfv/</a>
<br>
[4] - <a href="https://pdfs.semanticscholar.org/99d4/73437ea95dddc983a197e96569505be757f2.pdf">https://pdfs.semanticscholar.org/99d4/73437ea95dddc983a197e96569505be757f2.pdf</a>
</div>
