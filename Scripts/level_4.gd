extends Node2D

@onready var backgrounds: Array = [
	$ocean_bg1,
	$ocean_bg4,
	$ocean_bg2,
	$ocean_bg5,
	$ocean_bg6,
	$ocean_bg8
]

var current_bg_index: int = 0

@onready var player = $Player
@onready var finish_line = $finish_line

func _ready() -> void:
	for i in range(backgrounds.size()):
		if i == 0:
			backgrounds[i].modulate.a = 1.0
			backgrounds[i].show()
		else:
			backgrounds[i].modulate.a = 0.0
			backgrounds[i].hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player != null and finish_line != null:
		# Tính % tiến độ: Lấy tọa độ X hiện tại chia cho tọa độ X của đích đến
		var progress_percent = (player.global_position.x / finish_line.global_position.x) * 100
		progress_percent = clampf(progress_percent, 0.0, 100.0) #Khong cho vượt quá 100 hoặc nhỏ hơn 0
		check_and_update_background(progress_percent)
		
		if player.global_position.y > 730.0 or player.global_position.y < -1000.0:
			if player.has_method("die"):
				player.die()
		
func check_and_update_background(progress_percent: float) -> void:
	#Tự động tính mốc chuyển cảnh, có 6 background cho màn này thì mỗi bg cần 100 / 6
	var percent_per_bg = 100.0 / backgrounds.size()
	# Tính ra index: VD 25% / 16.66 = 1.5 -> Ép về số nguyên (int) là 1 -> Chuyển sang bg 2
	var target_index: int = int(progress_percent / percent_per_bg)
	
	target_index = clampi(target_index, 0, backgrounds.size() - 1)
	
	if target_index != current_bg_index:
		_transition_to_bg(target_index)
		
func _transition_to_bg(new_index: int) -> void:
	var old_bg = backgrounds[current_bg_index]
	var new_bg = backgrounds[new_index]
	
	current_bg_index = new_index
	new_bg.show()
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(old_bg, "modulate:a", 0.0, 2.0)
	tween.tween_property(new_bg, "modulate:a", 1.0, 2.0)
	
	tween.set_parallel(false)
	tween.tween_callback(old_bg.hide)
	
