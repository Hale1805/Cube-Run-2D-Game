extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.die()

#Hàm tự động dọn dẹp khi Lava khuất hoàn toàn khỏi màn hình
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Tìm camera đang hoạt động trong màn chơi
	var camera = get_viewport().get_camera_2d()
	
	if camera:
		#Lấy chiều rộng của màn hình
		var viewport_width = get_viewport_rect().size.x
		
		#Tính khoảng cách từ tâm ra tới mép trái (chia đôi chiều rộng)
		var half_width = (viewport_width / 2.0) / camera.zoom.x
		
		#Tính tọa độ mép trái chuẩn xác
		var left_edge = camera.get_screen_center_position().x - half_width
		
		if global_position.x < (left_edge - 100):
			queue_free()
