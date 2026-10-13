extends Control

@export_multiline var dialogues: Array[String]
@export_file("*.tscn") var next_scene_path: String

var current_line: int = 0

var current_tween: Tween

@onready var text_label = $TextLabel
@onready var player_sprite = $PlayerSprite
@onready var boss_sprite = $BossSprite

func _ready() -> void:
	play_next_line()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		if text_label.visible_ratio < 1.0:
			if current_tween and current_tween.is_valid():
				current_tween.kill()
			text_label.visible_ratio = 1.0
		else:
			current_line += 1
			play_next_line()
			
func play_next_line() -> void:
	if current_line < dialogues.size():
		var raw_text = dialogues[current_line]
		
		if raw_text.strip_edges() == "":
			current_line += 1
			play_next_line()
			return
			
		var display_text = ""
		
		#Nhận diện người nói qua dấu "|"
		if "|" in raw_text:
			var parts = raw_text.split("|")
			var speaker = parts[0]
			display_text = parts[1]
			
			#Bật ảnh đúng người nói, tắt ảnh người kia
			player_sprite.visible = (speaker == "Player")
			boss_sprite.visible = (speaker == "Boss")
		else:
			# Lời dẫn: Tắt cả 2 ảnh
			display_text = raw_text
			player_sprite.visible = false
			boss_sprite.visible = false
		
		text_label.text = display_text
		text_label.visible_ratio = 0.0 # Bắt đầu ở mức 0% chữ
		
		# Hủy tween cũ nếu còn sót lại trước khi tạo tween mới
		if current_tween and current_tween.is_valid():
			current_tween.kill()
			
		current_tween = create_tween()
		var duration = display_text.length() * 0.02
		current_tween.tween_property(text_label, "visible_ratio", 1.0, duration)
	else:
		#Hết thoại thì chuyển cảnh
		TransitionManager.change_scene(next_scene_path)


func _on_skip_button_pressed() -> void:
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	#Chuyển thẳng tới scene tiếp theo
	TransitionManager.change_scene(next_scene_path)
