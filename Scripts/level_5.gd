extends Node2D

@onready var player = $Player
@onready var bg1 = $underwater1
@onready var bg2 = $underwater2

@onready var finish_line = $finish_line

# Biến khóa để đảm bảo hiệu ứng đổi nền chỉ chạy 1 lần
var has_swapped_bg: bool = false

func _ready() -> void:
	# Khởi tạo: Hiện nền 1, ẩn nền 2
	bg1.modulate.a = 1.0
	bg1.show()
	
	bg2.modulate.a = 0.0
	bg2.hide()

func _process(_delta: float) -> void:
	if player != null and finish_line != null:
		# 1. Tính toán % tiến độ
		var progress_percent = (player.global_position.x / finish_line.global_position.x) * 100.0
		
		# 2. Đổi nền nếu vượt qua mốc 62% và chưa từng đổi
		if progress_percent >= 62.0 and not has_swapped_bg:
			swap_backgrounds()
			
		# 3. Cơ chế giới hạn chiều lên xuống (quá thấp hoặc quá cao thì chết)
		if player.global_position.y > 730.0 or player.global_position.y < -80.0:
			if player.has_method("die"):
				player.die()

func swap_backgrounds() -> void:
	has_swapped_bg = true # Khóa ngay lập tức
	
	bg2.show()
	
	var tween = create_tween()
	tween.set_parallel(true)
	# Mờ chéo trong 2 giây
	tween.tween_property(bg1, "modulate:a", 0.0, 2.0)
	tween.tween_property(bg2, "modulate:a", 1.0, 2.0)
	
	tween.set_parallel(false)
	tween.tween_callback(bg1.hide)
