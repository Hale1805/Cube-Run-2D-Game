extends Control

@onready var progress_bar = $ProgressBar

func _process(delta: float) -> void:
	# Tăng thanh tải lên 50 đơn vị mỗi giây
	progress_bar.value += 50 * delta 
	
	# Khi đầy 100% thì tự động chuyển sang Home Screen
	if progress_bar.value >= 100:
		get_tree().change_scene_to_file("res://home_screen.tscn")
