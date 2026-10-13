# **NGẮN GỌN KHÔNG DÀI DÒNG**

## Dự án Cube Run được phát triển trên nền tảng Godot Engine 4.7.2. Khác với các framework lập trình thuần code, kiến trúc của Godot được xây dựng dựa trên khái niệm trực quan bao gồm Node (Nút) và Scene (Cảnh).

## Dưới đây là các khái niệm cốt lõi cần hiểu để nắm được cấu trúc dự án:

**A. Node (Nút)**
Node là đơn vị nhỏ nhất trong Godot. Có nhiều loại Node. Mỗi loại Node đảm nhiệm một chức năng duy nhất. Bằng cách lắp ráp các Node này lại với nhau, ta tạo ra các đối tượng phức tạp.
Trong dự án này, một số Node cơ bản được sử dụng nhiều nhất bao gồm:

  - Sprite2D: Node dùng để hiển thị hình ảnh 2D (ví dụ: hình khối vuông của nhân vật, hình ảnh quái vật, ảnh nền background).

  - CollisionShape2D: Node định hình khung va chạm vật lý
  - ColiisionPolygon2D: Y hệt Shape2d, chỉ đơn giản là thay vì vẽ khung va chạm theo các hình thù cố định thì Polygon được vẽ tùy ý

  - Control (Button, Label, TextureRect...): Các Node chuyên dùng để thiết kế Giao diện người dùng (UI)

  - AudioStreamPlayer: Node chịu trách nhiệm phát âm thanh.

  - Area2D, StaticBody2D sẽ giải thích ở phần D

**B. Scene (Cảnh):**

Nếu ví Node là 1 viên gạch, thì Scene chính là 1 căn phòng hoặc 1 ngôi nhà được xây lên từ những viên gạch đó.

Một Scene là một tập hợp các Node được tổ chức theo dạng cây thư mục (cấp cha - con). Các Scene được lưu dưới định dạng file .tscn

Trong Cube Run, Scene được ứng dụng theo 2 hướng chính:
  - Scene đóng vai trò là 1 Đối tượng: Ví dụ file gai_nhon_origin.tscn là 1 Scene độc lập. Nó có Node gốc là Area2D, bên trong nó có chứa 2 Node con. Sprite2D để hiển thị hình ảnh tam giác và khung va chạm.
    <img width="873" height="325" alt="image" src="https://github.com/user-attachments/assets/a32eaf5b-2c4e-4288-9e58-e24e900a9db4" />

  - Scene đóng vai trò là một màn chơi (Level): Ví dụ file level_8.tscn. Các Scene này đóng vai trò như 1 vùng không gian lớn, chứa ảnh nền, chứa giao diện và các chướng ngại vật bên trong.
  - Có thể hiểu rằng các Scene Level này chứa các Scene loại đối tượng ở trên, kết hợp lại tạo thành 1 màn chơi lớn.
    <img width="1871" height="647" alt="image" src="https://github.com/user-attachments/assets/c77cbf2d-c592-4cff-a20b-10f60df612c5" />
- Có thể thấy nhanh qua hình minh họa ở trên, level_8 đang chứa rất nhiều Scene con bên trong nó.

**C. Khởi tạo và tái sử dụng**

Godot có khẳ năng nhúng Scene này vào bên trong Scene khác. Kiểu như ta có thể tạo nhiều Scene đối tượng rồi ném vào Các Scene khác. Đó chính là cách các level được tạo nên.

Cái này hay ở chỗ có thể tiết kiệm thời gian thiết kế và code, ví dụ như có 1 đối tượng là Player đi, nó sẽ di chuyển trong level. Thay vì mỗi level ta lại phải thiết kế và code 1 con Player rất lâu, thì ta thiết kế Player 1 lần duy nhất, 
đóng gói nó lại thành 1 Scene và giờ đây có thể ném nó vào bất cứ Level nào mà mình muốn.

Tiếp theo là Godot có thể cho kế thừa Scene. Có thể hiểu đơn giản là ta ban đầu tạo 1 Scene (tạm đặt là base_scene.tscn). Trong scene gốc này có 1 node chứa ảnh và 1 node va chạm. Ta dự định để nó làm Block Scene (Những đối tượng
mà Player có thể di chuyển bình thường trên đó). Và bây giờ ta có thể tận dụng Scene gốc này để tạo nhiều Scene khác tương tự chỉ bằng 1 nút bấm thay vì cứ phải đi thêm node ảnh và node va chạm mỗi lần tạo Scene mới.
Và ta chỉ cần thay đổi hình ảnh, chỉnh lại khung va chạm là ta đã có 1 Scene hoàn toàn mới.

**D. Hệ thóng vật lý và tương tác**

Bên cạnh các Node được giới thiệu ở mục A, hệ thống vật lý là cốt lõi để tạo enen logic của trò chơi.

Dự án phân chia các đối tượng vật lý thành 3 nhóm Node chính để tối ưu hóa hiệu năng xử lý:
  - **StaticBody2D (Vật thể tĩnh)**: Đóng vai trò là các khối vật chất rắn bất động. Là khung xương vững chắc cho màn chơi. Nhân vật có thể di chuyển bình thường trên bề mặt của nó (miễn là được vẽ khung va chạm phù hợp)
    <img width="1495" height="906" alt="image" src="https://github.com/user-attachments/assets/faccf052-e7c5-40b6-960e-ebe0d1a9796e" />
    <img width="1267" height="557" alt="image" src="https://github.com/user-attachments/assets/fa4c8065-6307-4839-945b-dfc9a078ab50" />

  - Nhìn vào hình trên, có thể thấy rằng Scene có tên bench_block này có Node gốc là StaticBody2D, nó có 1 node chứa ảnh và 1 node vẽ vùng va chạm. Bạn có thể dễ dàng nhìn thấy ta phải vẽ khung va chạm khớp với hình ảnh 2D,
sau đó gắn cho chúng trùng nhau. Vây là đã có 1 đối tượng mà nhân vật có thể di chuyển trên đó.

- **Lưu ý: Mọi Scene mà node gốc của nó là StaticBody2D sẽ được đặt tên có đuôi block để dễ nhận biết, và gọi nhóm này là Block Scene cho tiện (như ví dụ vừa rồi là bench_block.tscn)**

- Tuy nhiên không phải cứ là Block Scene là có thể đi được trên mọi trường hợp, chỉ có những mặt phẳng có độ dốc vừa phải thì player mới di chuyển được. Nhìn hình minh họa bên dưới:
  <img width="965" height="476" alt="image" src="https://github.com/user-attachments/assets/73c95354-7915-4e71-a6d8-09912b03e124" />
- Có thể hiểu rằng đối với mặt phẳng bình thường thì di chuyển thoải mái (được đánh dấu tích), tuy nhiên tôi có minh họa có 1 chướng ngại vật kiểu Block chắn ngang, nếu như player cứ thế mà di chuyển, nó sẽ đâm vào
chỗ được mũi tên màu đỏ chỉ đến và sẽ chết. Do đó nó phải nhảy từ dưới lên để tiếp tục di chuyển trên bề mặt đối tượng Block

- **Area2D (Vùng cảm biến)**: Khác với vật thể tĩnh, Area2D là 1 vùng không gian "ảo", không có tính rắn nên mọi vật thể đều có thể đi xuyên qua. Chức năng chính của nó là làm "radar" phát tín hieuj khi có 1 đối tượng khác bước vào
hoặc rời khỏi ranh giới của nó. Trong dự án Cube Run, Area2D được dùng để phát tín hiệu là chủ yếu. Nó được sử dụng cho các chướng ngại vật loại đụng vào là chết luôn (spike). **Do đó gọi chung những Scene dạng này là Spike Secne**

- **CharacterBody2D**: Là Node chuyên dụng dành cho Player. Nó cho phép áp dụng trọng lực rơi tự do và cung cấp các hàm API có sẵn để dev dễ dàng điều khiển nhân vật chạy, nhảy thông qua code mà không cần tự viết lại các thuật toán tính tán va chạm phức tạp.


**E. Giải thích ngắn gọn về cách kết nối code cho Scene và cách kết nối tín hiệu (Signal)**
<img width="375" height="536" alt="image" src="https://github.com/user-attachments/assets/91fa8b0b-d717-4f54-8a27-b0cfbd1c45c5" />
- Các Scene đã được gắn với code thì sẽ xuất hiện 1 biểu tượng cuộn giấy như ở khu vực khoanh tròn. Còn nếu chưa liên kết code thì có thể liên kết thông qua nút ở trên.
- Không phải Scene nào cũng cần kết nối với code, và cũng không phải Scene nào cũng cần kết nối Signal. Signal thường được kết nối với Scene có chức năng đặc biệt. Ví dụ như các Spike Scene bắt buộc phải kết nối Signal.
- Kết nối Signal được minh họa như hình dưới:

<img width="977" height="297" alt="image" src="https://github.com/user-attachments/assets/46e17ad0-7a21-49e7-b295-114068e2593d" />

- Như đã biết các Spike Scene nếu không làm gì thì mọi thứ có thể đi xuyên qua nó. Vì thế như hình trên, Scene crystal_4_spike đã được kết nối với tín hiệu body_entered.
- Và như tên gọi của nó, khi có đối tượng khác mà chạm vào nó, ngay lập tức tín hiệu này sẽ đi đến hàm code đã được liên kết với tín hiệu (on_body_entered).
- Mà hàm này lại có công dụng giết chết Player ngay lập tức. Và thế là từ code và kết nối signal, 1 Spike Scene đã có thể giết Player mỗi khi Player chạm vào chúng.
<img width="507" height="170" alt="image" src="https://github.com/user-attachments/assets/bce498df-11e9-4b5e-8048-fc39be3b2687" />

=========================================================================================================================================
# **Một số lưu ý nhỏ và giải thích ngắn gọn các thư mục, các file (Nên đọc sau khi đọc xong cái trên)**

1. 99% Code đang nằm trong thư mục Scripts, 1 file code còn lại thuộc về thư mục level8_boss (file boss.gd)
2. Dự án chủ yếu là các file Scene (.tscn), code logic (.gd) thì như mục 1 đã nói rồi
3. Giải thích nhanh các thư mục
   - Assets: Chủ yếu chứa các hình ảnh và âm thanh linh tinh (cho level 1 và 2 là nhiều)
   - Scripts: Chứa code
   - StoryScene: Chứa 3 Scene cốt truyện
   - font: chứa font chữ
   - furniture_block_scene và furniture_spike_scene: Chứa các Block Scene và Spike Scene cho level 1
   - Tương tự cho đến level 8
   - pad_and_ring: Chứa các Scene đệm nhảy và vòng nhảy (Pad là đệm nhảy, Ring là vòng nhảy)
   - pit_scene: Chứa các Scene con dốc
   - portal_scene: Chứa các Scene cổng chuyển đổi (từ dạng khối vuông bình thường có thể chuyển qua các dạng như ball, wave, ship)
   - saw_blade_scene: Chứa các Spike Scene nhưng hình ảnh là các lưỡi cưa
   - spike_scene: Chứa các Spike Scene cơ bản nhất
4.  Giải thích nhanh các file bên ngoài không thuộc thư mục nào
  - từ level_1 đến level_8.tscn là 8 Level chính của game
  - base_block và base_spike: Scene gốc để tạo các Block và Spike Scene nhanh hơn bằng cách kế thừa chúng
  - death_effect: hiệu ứng chết
  - finish_line.tscn: Scene kết thúc màn chơi (ném vào cuối level là xong)
  - home_screen: Màn hình chính khi mới vào game, bấm vào nút play ở màn hình này thì đi qua level menu
  - level_menu: Giao diện chứa các màn chơi của game (lựa chọn màn chơi và bấm vào để đi vào màn chơi ở giao diện này)
  - level_base: Level gốc để kế thừa khi thiết kế các level của game
  - splash_screen: Không quan trọng, next
  - story_screen: Scene cốt truyện gốc mà 3 cái Scene trong thư mục StoryScene kế thừa
  - transition_manager.tscn: Scene phục vụ việc reload màn chơi, chuyển scene mượt mà.

5. Giải thích nhanh các file code trong Scripts
  - bay_xoay.gd: Quản lý hành vi của bọn saw_blade Scene, có kế thừa hiệu ứng chết luôn của gai nhon origin
  - cyan_gravity_ring.gd: Xử lý logic cho mọi loại Ring (Vòng nhảy) (Tên file là cyan nhưng xử lý cho mọi màu nhé)
  - finish_line.gd: Xử lý hoạt ảnh khi chiến thắng
  - gai_nhon_origin.gd: Khi Player chạm vào thì chết luôn (gọi hàm die của player.gd)
  - global.gd: Là bộ não chạy ngầm của trò chơi. Khởi tạo Dictionary để ghi nhớ tiến độ hoàn thành của cả 8 màn chơi. Đếm thời gian và số lần thử. Lưu và đọc file lưu game trong ổ cứng (lưu tiến độ trò để nó không biến mất ngay cả khi tắt game)
  - gravity_pad_cyan: kết nối tín hiệu với cyan pad, gọi hàm xử lý (apply_gravity+pad) của player.gd
  - home_screen: chuyển cảnh sang level menu
  - jump+ơad_yellow: gọi hàm xử lý bên player.gd và truyền lực nảy là 1750
  - lava.gd: y hệt bọn gai nhon nhưng có thêm cơ chế tự hủy khi đi qua màn hình
  - level 2 4 5 6 7.gd: giúp chuyển background của màn chơi dựa theo % hiện tại (level 4 có nhiều background nên phức tạp hơn mấy file khác)
  - level_8.gd: Không chuyển background, mà đếm % của level để cho con boss xuất hiện, biến mất
  - portal_cube, ball, ship, wave: gọi hàm xử lý bên trong player.gd
  - level_menu.gd: Quản lý toàn bộ giao diện chọn 8 Level của game. Phụ trách việc hiển thị đúng hình nền, tên màn chơi và số % tiến độ mà người chơi đã đạt được, đồng thời tạo hiệu ứng chuyển động khi select qua lại giữa các level
  - transition_manager.gd: chuyển scene và reload level
  - story_screen: Quản lý việc hiển thị hội thoại và chuyển cảnh trong các đoạn cốt truyện của trò chơi
  - ui_layer: (Thuộc vè Node UILayer xuất hiện trong mọi level). Nó là code quản lý giao diện pause game, giao diện win game, và cả việc đo tiến độ màn chơi
  - void_ball: Một loại đạn của Boss, luôn bay sang trái, chạm vào thì chết luôn
  - world_environment: Tạo hiệu ứng chớp tắt ánh sáng cho level 1
  - boss.gd: Tự tìm hiểu đi, lười quá (nhớ là file này nằm bên level8_boss)
  - ## player.gd (FILE NÀY CỰC KỲ QUAN TRỌNG, TÌM HIỂU CHO KỸ, VÌ NÓ LIÊN KẾT VỚI RẤT NHIỀU FILE VÀ ĐỐI TƯỢNG KHÁC NHAU): Code quản lý các hành vi của Player (Hệ thống vật lý, phản hồi thao tác của người chơi, xử lý trạng thái sống chết, quản lý việc chuyển đổi sang các dạng khác thông qua việc đi qua portal
tương tác với Pad và Ring) Nói chung là rất nhiều thứ nằn trong này.

Hết rồi!
