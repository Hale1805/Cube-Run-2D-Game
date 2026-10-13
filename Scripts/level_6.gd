extends Node2D

@onready var player = $Player
@onready var finish_line = $finish_line 
@onready var bg1 = $bg1
@onready var bg2 = $bg2
@onready var bg3 = $bg3

# Dùng 2 biến cờ để kiểm soát 2 lần chuyển đổi
var has_swapped_to_bg2: bool = false
var has_swapped_to_bg3: bool = false

func _ready() -> void:
	# Khởi tạo: Chỉ hiện nền 1, ẩn nền 2 và 3
	bg1.modulate.a = 1.0
	bg1.show()
	
	bg2.modulate.a = 0.0
	bg2.hide()
	
	bg3.modulate.a = 0.0
	bg3.hide()

func _process(_delta: float) -> void:
	if player != null and finish_line != null:
		# Tính toán % tiến độ dựa theo trục X
		var progress_percent = (player.global_position.x / finish_line.global_position.x) * 100.0
		
		# Mốc 1: Đổi từ bg1 sang bg2 khi đạt 30%
		if progress_percent >= 30.0 and not has_swapped_to_bg2:
			swap_to_bg2()
			
		# Mốc 2: Đổi từ bg2 sang bg3 khi đạt 79%
		if progress_percent >= 79.0 and not has_swapped_to_bg3:
			swap_to_bg3()

func swap_to_bg2() -> void:
	has_swapped_to_bg2 = true # Khóa lệnh gọi lại lần 2
	bg2.show()
	
	var tween = create_tween()
	tween.set_parallel(true)
	# Mờ chéo trong 2 giây
	tween.tween_property(bg1, "modulate:a", 0.0, 2.0)
	tween.tween_property(bg2, "modulate:a", 1.0, 2.0)
	
	tween.set_parallel(false)
	tween.tween_callback(bg1.hide)

func swap_to_bg3() -> void:
	has_swapped_to_bg3 = true # Khóa lệnh gọi lại lần 2
	bg3.show()
	
	var tween = create_tween()
	tween.set_parallel(true)
	# Mờ chéo tiếp từ bg2 sang bg3 trong 2 giây
	tween.tween_property(bg2, "modulate:a", 0.0, 2.0)
	tween.tween_property(bg3, "modulate:a", 1.0, 2.0)
	
	tween.set_parallel(false)
	tween.tween_callback(bg2.hide)
