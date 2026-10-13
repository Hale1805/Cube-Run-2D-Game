extends "res://Scripts/gai_nhon_origin.gd"

#Từ khóa export giúp biến này hiển thị ra ngoài giao diện Godot
@export var spin_speed: float = 15.0

func _physics_process(delta: float) -> void:
	#Xoay node gốc liên tục
	#Vì hình ảnh và vùng va chạm là con của node này, chúng sẽ tự động xoay theo
	rotation += spin_speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
