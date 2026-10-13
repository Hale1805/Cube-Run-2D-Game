extends Area2D
var speed = 400.0

func _process(delta: float) -> void:
	# Đạn luôn bay sang trái (về phía người chơi)
	position.x -= speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.has_method("die"):
			body.die()
		queue_free() # Hủy viên đạn
