extends Node2D

@onready var player = $Player
@onready var finish_line = $finish_line
@onready var boss = $Boss

var start_x: float = 0.0
var total_distance: float = 0.0

func _ready() -> void:
	# Cấp quyền cho Boss biết Player đang ở đâu
	if boss:
		boss.player = player

	# Lấy tọa độ ban đầu để tính toán phần trăm
	if is_instance_valid(player) and is_instance_valid(finish_line):
		start_x = player.global_position.x
		total_distance = finish_line.global_position.x - start_x

func _process(_delta: float) -> void:
	if not is_instance_valid(player) or not is_instance_valid(boss) or total_distance <= 0:
		return
		
	var current_distance = player.global_position.x - start_x
	var percentage = (current_distance / total_distance) * 100.0
	
	# Gọi các giai đoạn của Boss theo %
	if percentage >= 96.0:
		boss.die()
	elif percentage >= 66.0:
		boss.appear("phase2")
	elif percentage >= 37.0:
		boss.disappear()
	elif percentage >= 22.0:
		boss.appear("phase1")
