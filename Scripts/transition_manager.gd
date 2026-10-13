extends CanvasLayer

@onready var color_rect = $ColorRect

func _ready() -> void:
	# Mặc định bức màn trong suốt khi game vừa bật
	color_rect.modulate.a = 0.0

func reload_level() -> void:
	var tween = create_tween()
	# Bước 1: Kéo rèm đen che kín lại trong 0.1s
	tween.tween_property(color_rect, "modulate:a", 1.0, 0.1)
	await tween.finished
	
	# Bước 2: Âm thầm load lại màn chơi ở phía sau bức màn
	get_tree().reload_current_scene()
	
	# Bước 3: Mở rèm ra từ từ trong 0.3s
	var tween2 = create_tween()
	tween2.tween_property(color_rect, "modulate:a", 0.0, 0.3)

func change_scene(target_path: String) -> void:
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, 0.1)
	await tween.finished
	
	#Load scene mới thay vì reload như trên
	get_tree().change_scene_to_file(target_path)
	
	var tween2 = create_tween()
	tween2.tween_property(color_rect, "modulate:a", 0.0, 0.2)
