extends CharacterBody2D

var death_effect_scene = preload("res://death_effect.tscn")

# Các thông số lực nhảy và tốc chạy
const RUN_SPEED = 700.0      
const JUMP_VELOCITY = -1222.0
var jump_buffer_timer: float = 0.0
const WAVE_SPEED_X = 950.0
const WAVE_SPEED_Y = 900.0

#Biến đánh dấu xem nhân vật đang là khối vuông hay tàu bay hay là ball hoặc wave
var is_ship_mode: bool = false
var is_ball_mode: bool = false
var is_wave_mode: bool = false

#Biến lưu trạng thái bấm phím
var is_holding_jump: bool = false

var is_dashing: bool = false # Đánh dấu xem nhân vật có đang lướt bằng dash ring không

#Biến lưu ring nhân vật đang đi qua
var current_ring = null

var is_dead: bool = false

# Nhận diện Node ảnh để xử lý xoay
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

# Tăng trọng lực lên 4 lần để khối vuông rơi dứt khoát, không bị trôi nổi
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 6.5
#Khai báo hướng trọng lực: 1 là bình thường, -1 là đảo ngược
var gravity_dir: int = 1
#Biến kiểm soát độ nặng khi bay (giúp giảm gia tốc rơi khi chạm vào gravity ring)
var current_gravity_multi: float = 1.0

func _physics_process(delta):
	#Jump Buffer và xử lý ring
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	if jump_buffer_timer > 0 and current_ring != null:
		current_ring.activate_ring(self)
		current_ring = null
		jump_buffer_timer = 0.0
		
	#Logic đảo trọng lực cho khối tròn
	if is_ball_mode and jump_buffer_timer > 0 and is_on_floor():
		gravity_dir *= -1
		
		#Đảo chiều khái niệm mặt đất và lật hình ảnh
		if gravity_dir == 1:
			up_direction = Vector2.UP
			sprite.flip_v = false
		else:
			up_direction = Vector2.DOWN
			sprite.flip_v = true
		
		#Thêm 1 chút lực nảy nhẹ để tách ball khỏi bề mặt ngay lập tức
		velocity.y = 150 * gravity_dir
		jump_buffer_timer = 0.0 #Tránh bị lật liên tục
		
	if is_ship_mode:
		#LOGIC TÀU BAY
		#1. Trọng lực kéo xuống nhẹ hơn
		velocity.y += (gravity * 0.35) * delta
		#2. giữ phím để đẩy lên
		if is_holding_jump:
			velocity.y -= 6000 * delta
		#3. Giới hạn tốc độ rơi/bay lên
		velocity.y = clamp(velocity.y, -600, 600)
		#4. Hiệu ứng ngóc đầu / cắm đầu
		var target_rotation = velocity.y * 0.0015
		target_rotation = clamp(target_rotation, -0.6, 0.6) 
		sprite.rotation = lerp(sprite.rotation, target_rotation, 12.0 * delta)
	
	elif is_wave_mode:
		#LOGIC WAVE
		if is_holding_jump:
			velocity.y = -WAVE_SPEED_Y * gravity_dir
		else:
			velocity.y = WAVE_SPEED_Y * gravity_dir
		#Xoay hình ảnh
		var target_rotation_deg = rad_to_deg(atan2(velocity.y, velocity.x))
		
		sprite.rotation_degrees = move_toward(sprite.rotation_degrees, target_rotation_deg, 1500 * delta)
	
	elif is_ball_mode:
		#LOGIC KHỐI TRÒN
		#1. Kiểm tra trạng thái lướt (để sử dụng dash ring y hệt khối vuông)
		if is_dashing:
			if not is_holding_jump:
				is_dashing = false
			else:
				velocity.y = 0
		
		if not is_dashing:
			#Trọng lực kéo xuống/lên (rơi nhanh như khối vuông)
			velocity.y += (gravity * current_gravity_multi * gravity_dir) * delta
		#2. Hiệu ứng lăn tròn liên tục
		#Nhân với gravity_dir giúp nó tự xoay ngược lại khi bám trên trần
			sprite.rotation_degrees += 720 * gravity_dir * delta
		else:
			sprite.rotation_degrees += 1000 * gravity_dir * delta
		
	else:
		#LOGIC KHỐI VUÔNG
		if is_dashing:
			if not is_holding_jump:
				#Nếu người chơi nhả chuột ra thì hủy trạng thái dash
				is_dashing = false
			else:  #Nếu vẫn đang đè chuột thì khóa cứng Y để bay ngang
				velocity.y = 0

		# 1. Trọng lực & Xoay khối vuông
		if not is_dashing:
			velocity.y += (gravity * current_gravity_multi * gravity_dir) * delta  #Trọng lực (rơi xuống) chỉ áp dụng khi không lướt
		
		if not is_on_floor():
			# Xoay liên tục khi ở trên không (tốc độ xoay 360 độ/giây)
			sprite.rotation_degrees += 360 * gravity_dir * delta 
		else:
			#Khi chạm đất thì cho trọng lực trở về bình thường
			current_gravity_multi = 1.0
			
			# 2. Xoay khối vuông khớp với độ nghiêng của mặt dốc
			# Tính góc của mặt đất (phẳng = 0, dốc lên = âm, dốc xuống = dương)
			var slope_angle = rad_to_deg(get_floor_normal().angle()) + 90.0
		
			var current_rot = sprite.rotation_degrees
			# Tính toán góc 90 độ gần nhất nhưng ĐƯỢC CỘNG THÊM độ nghiêng của dốc
			var target_rot = snapped(current_rot - slope_angle, 90) + slope_angle
		
			# Dùng lerp để khối vuông nghiêng êm ái hơn khi vừa tiếp đất
			sprite.rotation_degrees = lerp(sprite.rotation_degrees, target_rot, 30.0 * delta)
		

		# 3. Lệnh Nhảy (Đè nút để nhảy liên tục)
		if is_holding_jump and is_on_floor():
			velocity.y = JUMP_VELOCITY * gravity_dir
			jump_buffer_timer = 0.0 #Reset buffer lệnh nhảy để tránh tình trạng double jump
									#khi mà nhảy lên gặp ngay ring ở gần đó. (Lệnh nhảy được lưu trong 0.15s
									#nếu mà trong 0.15s đó gặp ngay cái ring thì tự động nảy khỏi ring luôn
#=================================================================================
	# 4. Tự động chạy
	if is_wave_mode:
		velocity.x = WAVE_SPEED_X
	else:
		velocity.x = RUN_SPEED
	move_and_slide()
	
	# Kiểm tra xem vừa tông trúng cái gì
	for i in get_slide_collision_count():
		var va_cham = get_slide_collision(i)
		var vat_the_bi_tong = va_cham.get_collider()
		
		# Nếu vật thể tông trúng thuộc nhóm "Deadly"
		if vat_the_bi_tong != null and vat_the_bi_tong.is_in_group("Deadly"):
			die()
			return
	
	# 5. Xử lý đâm tường (Game Over)
	if is_on_wall():
		die()

func die():
	if is_dead:
		return
	is_dead = true #Trạng thái chết, khi reload màn chơi thì quay về false
	
	#1. Ngừng tính toán vật lý (nhân vật đứng im, không rơi, không chạy...)
	set_physics_process(false)
	#2. Giấu hình ảnh nhân vật đi
	sprite.visible = false
	#3. Thêm vụ nổ
	var effect = death_effect_scene.instantiate()
	effect.global_position = global_position  #Đặt vụ nổ ngay vị trí nhân vật chết
	get_parent().add_child(effect) #Thêm vụ nổ ra ngoài màn chơi
	#4. Kích hoạt vụ nổ
	effect.emitting = true
	#5. Chờ 1s để xem hiệu ứng nổ
	await get_tree().create_timer(1.0, false).timeout
	#6. Reset màn chơi
	get_tree().paused = false
	Global.level_attempts += 1
	TransitionManager.reload_level()

func enter_ship_mode():
	is_ship_mode = true
	is_ball_mode = false
	is_wave_mode = false
	#Thay ảnh khối vuông thành ảnh tàu bay
	$Sprite2D.texture = load("res://Assets/Ship.png")
	#Reset góc xoay về thẳng đứng
	$Sprite2D.rotation = 0
	collision_shape.shape.radius = 27.0

func enter_cube_mode():
	is_ship_mode = false
	is_ball_mode = false
	is_wave_mode = false
	$Sprite2D.texture = load("res://Assets/Cube065.png")
	$Sprite2D.rotation_degrees = snapped($Sprite2D.rotation_degrees, 90)
	collision_shape.shape.radius = 27.0

func enter_ball_mode():
	is_ship_mode = false
	is_ball_mode = true
	is_wave_mode = false
	$Sprite2D.texture = load("res://Assets/Ball006.png")
	collision_shape.shape.radius = 27.0

func enter_wave_mode():
	is_ship_mode = false
	is_ball_mode = false
	is_wave_mode = true
	$Sprite2D.texture = load("res://level7_assets/Wave.png")
	collision_shape.shape.radius = 16.0
	$Sprite2D.rotation_degrees = 0
	
func _unhandled_input(event: InputEvent) -> void:
	# Hàm này chỉ nhận tín hiệu khi KHÔNG bấm vào UI (như nút Pause)
	if event.is_action("ui_accept"):   #Nhận tín hiệu true nhấn và thả chuột (tay khi trên điện thoại)
		# Cập nhật biến này thành true nếu đang đè nút, và false nếu nhả nút ra
		is_holding_jump = event.is_pressed()  #Ở trên nhận cả nhấn và thả, nhưng ở đây chỉ có nhấn mới khiến biến này = true
		
		if event.is_action_pressed("ui_accept"):
			jump_buffer_timer = 0.15
			
#Hàm dùng cho pad bình thường
func apply_pad_jump(bounce_force: float) -> void:
	#Ghi đề hoàn toàn lực nhảy hiện tại bằng lực đẩy của đệm
	velocity.y = -bounce_force *gravity_dir
	
#Hàm dùng cho cyan pad
func apply_gravity_pad(bounce_force: float) -> void:
	#Đảo ngược hướng trọng lực (từ 1 thành -1 và ngược lại)
	gravity_dir *= -1
	#Cập nhật khái niệm mặt đất cho godot
	if gravity_dir == 1:
		up_direction = Vector2.UP
		sprite.flip_v = false
	else:
		up_direction = Vector2.DOWN
		sprite.flip_v = true
	#ép khối vuông hướng về phía trọng lực mới
	velocity.y = bounce_force * gravity_dir
	current_gravity_multi = 0.75

#2 hàm dưới dùng để nhận diện khi khối vuông bay vào và bay ra khỏi ring
func enter_ring(ring_node) -> void:
	current_ring = ring_node
func exit_ring(ring_node) -> void:
	#Chỉ xóa nếu ring vừa thoát ra là cái ring đang lưu
	if current_ring == ring_node:
		current_ring = null

#Hàm dùng riêng cho Green Ring
func apply_green_ring() -> void:
	#Đaao ngược hướng trọng lực
	gravity_dir *= -1
	#Cập nhật khái niệm mặt đất và đảo hình
	if gravity_dir == 1:
		up_direction = Vector2.UP
		sprite.flip_v = false
	else:
		up_direction = Vector2.DOWN
		sprite.flip_v = true
	#Không áp dụng tăng velocity.y nhân với lực nhảy ở đây, để tự rơi và đổi trọng lực -> tạo hiệu ứng xuyên qua
	velocity.y *= 0.7
	current_gravity_multi = 0.7
	
# Hàm dùng riêng cho Dash Ring
func apply_dash_ring() -> void:
	is_dashing = true
	velocity.y = 0 # Đưa vận tốc dọc về 0 để khối vuông bay ngang
