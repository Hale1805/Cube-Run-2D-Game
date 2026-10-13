extends Area2D

# Đưa biến lực nảy ra ngoài Inspector để dễ chỉnh cho từng loại đệm
@export var jump_force: float = 1750.0

func _on_body_entered(body: Node2D) -> void:
	# Kiểm tra xem vật thể giẫm lên đệm có phải là Player không
	if body.name == "Player":
		
		# Gọi hàm nhận lực bên phía Player
		if body.has_method("apply_pad_jump"):
			body.apply_pad_jump(jump_force)
