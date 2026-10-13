extends Node2D

@onready var player = $Player
@onready var finish_line = $finish_line

@onready var sunset_bg = $SunsetBG
@onready var night_bg = $NightBG

var start_x: float = 0.0
var has_changed_to_night: bool = false #Khóa lệnh chuyển background

func _ready() -> void:
	if player != null:
		start_x = player.global_position.x

func _process(delta: float) -> void:
	#Chỉ tính toán nếu chưa chuyển background và đã gán đủ player + finish_line
	if not has_changed_to_night and player != null and finish_line != null:
		var current_distance = player.global_position.x - start_x
		var total_distance = finish_line.global_position.x - start_x
		
		if total_distance > 0:
			var progess = (current_distance / total_distance) * 100
			
			if progess >= 51.0:
				has_changed_to_night = true
				change_time_to_night()

func change_time_to_night() -> void:
	var tween = create_tween()
	# set_parallel(true) giúp 2 hành động xảy ra CÙNG MỘT LÚC
	tween.set_parallel(true) 
	
	# Hoàng hôn từ từ mờ đi thành tàng hình trong 4 giây
	tween.tween_property(sunset_bg, "modulate:a", 0.0, 4.0)
	
	# Cảnh Đêm từ từ hiện rõ lên trong 4 giây
	tween.tween_property(night_bg, "modulate:a", 1.0, 4.0)
