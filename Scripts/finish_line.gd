extends Area2D

var is_finished: bool = false
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_finished:
		is_finished = true
		# 1. Tắt vật lý để khối vuông lơ lửng ngay lập tức
		body.set_physics_process(false)
		
		if "velocity" in body:
			body.velocity = Vector2.ZERO 
			
		# Cài đặt thời gian (1.5 giây để tạo cảm giác slow-motion chậm rãi)
		var duration = 1.5
		
		# --- TWEEN 1: Xử lý trục X, Góc xoay và Kích thước ---
		var main_tween = create_tween()
		main_tween.set_parallel(true)
		
		# Trục X: Bị hút mạnh dần vào tâm cửa (Dùng CUBIC và EASE_IN)
		main_tween.tween_property(body, "global_position:x", global_position.x, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		
		# Xoay chậm đúng 1 vòng (360 độ). Dùng SINE để cảm giác xoay rất mượt
		main_tween.tween_property(body, "rotation_degrees", body.rotation_degrees + 360.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
		# Thu nhỏ dần về 0 ở tâm cửa
		main_tween.tween_property(body, "scale", Vector2.ZERO, duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		
		
		# --- TWEEN 2: Xử lý trục Y (Tạo vòng cung nhảy lên) ---
		var arc_tween = create_tween()
		# Nửa đầu: Nảy lên cao hơn vị trí hiện tại 180 pixel
		var jump_peak = body.global_position.y - 180.0 
		arc_tween.tween_property(body, "global_position:y", jump_peak, duration * 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		# Nửa sau: Rơi tụt xuống tâm
		arc_tween.tween_property(body, "global_position:y", global_position.y, duration * 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		
		
		# 3. Chờ main_tween chạy xong thì gọi hàm kết thúc
		main_tween.set_parallel(false)
		main_tween.tween_callback(trigger_win_screen)
	
func trigger_win_screen() -> void:
	# Gọi hàm show_win_screen() của bất kỳ Node nào đang mang mác "UI_Manager"
	get_tree().call_group("UI_Manager", "show_win_screen")
	
	
