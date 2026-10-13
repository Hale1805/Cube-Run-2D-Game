extends Node2D

@onready var player = $Player
@onready var finish_line = $finish_line

# Tham chiếu đến các background
@onready var bg2 = $bg2
@onready var bg4 = $bg4
@onready var bg1 = $bg1

# Các biến phục vụ tính % quãng đường
var start_x: float = 0.0
var total_distance: float = 0.0

# Các cờ đánh dấu để hiệu ứng Tween chỉ được gọi 1 lần duy nhất
var passed_32: bool = false
var passed_54: bool = false

func _ready() -> void:
	# 1. Ép Player quay về trạng thái khối vuông
	if player != null and player.has_method("enter_cube_mode"):
		player.enter_cube_mode()
		
	# 2. Lấy tọa độ để tính phần trăm
	if is_instance_valid(player) and is_instance_valid(finish_line):
		start_x = player.global_position.x
		total_distance = finish_line.global_position.x - start_x
		
	# 3. Đặt trạng thái trong suốt ban đầu cho các phông nền
	bg2.modulate.a = 1.0 
	bg4.modulate.a = 0.0
	bg1.modulate.a = 0.0

func _process(_delta: float) -> void:
	# Liên tục kiểm tra tiến trình của người chơi
	if is_instance_valid(player) and total_distance > 0:
		var current_distance = player.global_position.x - start_x
		var percentage = (current_distance / total_distance) * 100.0
		
		# Kích hoạt chuyển bg2 -> bg4 ở mốc 32%
		if percentage >= 32.0 and not passed_32:
			passed_32 = true
			transition_bg(bg2, bg4)
			
		# Kích hoạt chuyển bg4 -> bg1 ở mốc 54%
		if percentage >= 54.0 and not passed_54:
			passed_54 = true
			transition_bg(bg4, bg1)

# Hàm xử lý làm mờ chéo 2 background
func transition_bg(bg_out, bg_in) -> void:
	var tween = create_tween()
	# set_parallel(true) giúp 2 lệnh tween bên dưới chạy cùng một lúc thay vì chờ nhau
	tween.set_parallel(true) 
	
	# Thời gian chuyển đổi đặt là 2 giây
	tween.tween_property(bg_out, "modulate:a", 0.0, 2)
	tween.tween_property(bg_in, "modulate:a", 1.0, 2)
