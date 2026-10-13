extends Area2D

# Lực nhảy của Ring yếu hơn nhảy đất (1222) một chút
@export var jump_force: float = 900.0 

#Dùng enum để tạo menu xổ xuống trên Inspector
enum RingType { NORMAL, CYAN_BOUNCE, GREEN_PASS, DASH_RING }
@export var type: RingType = RingType.NORMAL

# Nối tín hiệu body_entered của Area2D vào đây
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.has_method("enter_ring"):
			body.enter_ring(self)

# Nối tín hiệu body_exited của Area2D vào đây
func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		if body.has_method("exit_ring"):
			body.exit_ring(self)

# Hàm này được Player gọi khi người chơi bấm nút
func activate_ring(player_node) -> void:
	#Dựa vào lựa chọn trên menu để gọi đúng hàm xử lý
	match type:
		RingType.NORMAL:
			if player_node.has_method("apply_pad_jump"):
				player_node.apply_pad_jump(jump_force)
		RingType.CYAN_BOUNCE:
			if player_node.has_method("apply_gravity_pad"):
				player_node.apply_gravity_pad(jump_force)
		RingType.GREEN_PASS:
			if player_node.has_method("apply_green_ring"):
				player_node.apply_green_ring()
		RingType.DASH_RING:
			if player_node.has_method("apply_dash_ring"):
				player_node.apply_dash_ring()
