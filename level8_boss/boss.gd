extends Area2D

# Biến này để kéo thả file các scene đạn từ FileSystem vào Inspector
@export var void_ball_scene: PackedScene
@export var beam_1_scene: PackedScene
@export var beam_2_scene: PackedScene

var attack_step: int = 0 #Biến đếm combo từ 0 đến 4

@onready var anim = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer
@onready var collision = $CollisionShape2D

var time_passed: float = 0.0
var base_y: float = 300.0 # Độ cao lơ lửng của Boss trên màn hình
var base_distance_x: float = 600.0 # Khoảng cách Boss đứng trước Player
var is_dead: bool = false
var is_attacking: bool = false
var current_state: String = "" #Trạng thái mặc định

# Biến tham chiếu đến Player (sẽ được gán tự động khi thêm Boss vào Level)
var player: Node2D

func _ready() -> void:
	#Tắt boss ngay khi màn chơi vừa load
	current_state = "hidden"
	visible = false
	modulate.a = 0.0
	collision.set_deferred("disabled", true)
	attack_timer.stop()

func _process(delta: float) -> void:
	if is_dead or current_state == "hidden" or not is_instance_valid(player):
		return
		
	time_passed += delta
	
	#Di chuyển dọc: Lượn lên xuống bằng sin() với biên độ 100px
	var offset_y = sin(time_passed * 2.2) * 100.0
	
	#Di chuyển ngang: Di chuyển trước sau bằng cos() với biên độ 80px
	#Boss sẽ không bao giờ vượt qua biên độ +-80px so với base_distance_x (600)
	var offset_x = cos(time_passed * 1.5) * 80.0
	
	# Boss luôn đứng trước Player 600 pixel
	var target_x = player.global_position.x + base_distance_x + offset_x
	var target_y = base_y + offset_y
	
	global_position = Vector2(target_x, target_y)

#Các hàm điều khiển trạng thái
func appear(phase_name: String) -> void:
	if current_state == phase_name or is_dead: return
	
	current_state = phase_name
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0) #Tăng modulate lên 100% trong 1s
	collision.set_deferred("disabled", false) #Bật va chạm
	attack_step = 0
	attack_timer.start()
	
	#Tăng độ khó ở phase 2 (bắn nhanh hơn)
	if phase_name == "phase2":
		attack_timer.wait_time = 2.5
	else:
		attack_timer.wait_time = 3.0
		
func disappear() -> void:
	if current_state == "hidden" or is_dead: return
	current_state = "hidden"
	collision.set_deferred("disabled", true) #Tắt va chạm để player không đâm trúng boss tàng hình
	attack_timer.stop()
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0) #Giảm modulate về 0 trong 1s
	tween.tween_callback(func(): visible = false)

func die() -> void:
	if is_dead: return
	
	is_dead = true
	attack_timer.stop()
	collision.set_deferred("disabled", true)
	anim.play("death")
	
# Xử lý khi khối vuông đâm sầm trực tiếp vào Boss
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_dead and current_state != "hidden":
		if body.has_method("die"):
			body.die()

# Chuyển sang hoạt ảnh tấn công khi hết giờ
func _on_attack_timer_timeout() -> void:
	if not is_dead and not is_attacking:
		is_attacking = true
		anim.play("attack")

# Bắn đạn ở đúng khung hình con mắt chớp sáng
func _on_animated_sprite_2d_frame_changed() -> void:
	# Khung hình số 8 là lúc con mắt hội tụ năng lượng mạnh nhất
	if anim.animation == "attack" and anim.frame == 8:
		# Bắn void ball
		if attack_step ==0 or attack_step == 1:
			if void_ball_scene != null:
				var ball = void_ball_scene.instantiate()
				# Tọa độ sinh đạn lệch một chút so với tâm Boss để khớp với con ngươi
				ball.global_position = global_position + Vector2(-60, 20)
				get_parent().add_child(ball)
		#Bắn beam 1
		elif attack_step == 2 or attack_step == 3:
			if beam_1_scene != null:
				fire_beam(beam_1_scene, Vector2(-70, 0))
		#Bắn beam 2
		elif attack_step == 4:
			if beam_2_scene != null:
				fire_beam(beam_2_scene, Vector2(-70, 0))
		
		#Tăng biến đếm và reset nếu vượt quá 4
		attack_step += 1
		if attack_step > 4:
			attack_step = 0
			
#Hàm xử lý riêng việc bắn beam
func fire_beam(beam_scene: PackedScene, offset: Vector2) -> void:
	var beam = beam_scene.instantiate()
	add_child(beam) #Thêm beam làm con của boss, giúp beam di chuyển đồng bộ với chuyển động của boss
	beam.position = offset
	#Hẹn giờ 1.5s sau tự động xóa beam đi
	get_tree().create_timer(1.5).timeout.connect(beam.queue_free)
	

# Quay lại hoạt ảnh bay lượn sau khi tấn công xong
func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		is_attacking = false
		anim.play("move")
	elif anim.animation == "death":
		queue_free() # Biến mất hoàn toàn sau khi chạy xong 15 frame chết
