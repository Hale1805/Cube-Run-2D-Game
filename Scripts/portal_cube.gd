extends Area2D

func _on_body_entered(body):
	# Kiểm tra xem có đúng là Player chạm vào cổng không
	if body.name == "Player":
		# Gọi hàm biến về khối vuông
		if body.has_method("enter_cube_mode"):
			body.enter_cube_mode()
