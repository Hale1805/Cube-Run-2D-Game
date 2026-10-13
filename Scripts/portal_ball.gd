extends Area2D

func _on_body_entered(body):
	# Nếu người chạm vào cổng là Player
	if body.name == "Player":
		# Kích hoạt trạng thái lăn tròn
		if body.has_method("enter_ball_mode"):
			body.enter_ball_mode()
