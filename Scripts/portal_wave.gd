extends Area2D

func _on_body_entered(body):
	# Nếu đúng là Player chạm vào
	if body.name == "Player":
		# Kích hoạt trạng thái bay Zic-Zac
		if body.has_method("enter_wave_mode"):
			body.enter_wave_mode()
