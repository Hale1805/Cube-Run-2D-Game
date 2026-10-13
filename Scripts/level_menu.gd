extends Control

@onready var background = $TextureRect
@onready var play_button = $Level1Button
@onready var progress_bar = $Level1Button/HBoxContainer/ProgressBar
@onready var progress_label = $Level1Button/HBoxContainer/ProgressLabel
@onready var sfx_select = $SFX_Select

var current_level: int = 1
var total_levels: int = 8
var is_animating: bool = false #Khóa chống bấm spam mũi tên liên tục gây lỗi

#Lưu lại tọa độ gốc của khung level để dùng làm mốc trượt
@onready var original_pos = play_button.position

#Dictionary chứa toàn bộ thông tin hiển thị cho 8 level
var level_data: Dictionary = {
	1: {"name": "LEVEL 1: THE ROOM", "bg": preload("res://Assets/house_bg.webp")},
	2: {"name": "LEVEL 2: THE CITY", "bg": preload("res://Assets/bg_level_2.png")},
	3: {"name": "LEVEL 3: THE BEACH", "bg": preload("res://Assets/bg_level3.png")},
	4: {"name": "LEVEL 4: THE OCEAN", "bg": preload("res://Assets/bg_level_4.png")},
	5: {"name": "LEVEL 5: UNDERWATER", "bg": preload("res://Assets/bg_level_5.png")},
	6: {"name": "LEVEL 6: RETURN TO GROUND", "bg": preload("res://Assets/bg_level_6.png")},
	7: {"name": "LEVEL 7: THE MOUNTAIN", "bg": preload("res://Assets/bg_level_7.png")},
	8: {"name": "LEVEL 8: BECOME HUMAN", "bg": preload("res://Assets/bg_level_8.png")}
}

func _ready() -> void:
	#Lấy số level vừa chơi để hiển thị lên level menu, nếu lần đầu vào game thì current_level mặc định = 1
	current_level = Global.last_played_level
	update_ui(current_level)
	
func update_ui(level: int) -> void:
	var data = level_data[level]
	var best_score = Global.level_progress[level]
	play_button.text = data["name"]
	progress_bar.value = best_score
	progress_label.text = str(int(best_score)) + "%"
	
	background.texture = data["bg"]
	
#Hàm tạo hiệu ứng trượt
func slide_animation(step: int) -> void:
	if is_animating: return #Đang chạy hiệu ứng thì cấm bấm tiếp
	
	var next_level = current_level + step
	
	#Xoay vòng (quá 8 thì về 1, nhỏ hơn 1 thì quay về 8)
	if next_level > total_levels:
		next_level = 1
	elif next_level < 1:
		next_level = total_levels
	
	is_animating = true
	
	#Bước 1: Xử lý khung cũ bị đẩy ra ngoài
	#Tạo 1 bản sao của nút hiện tại
	var ghost = play_button.duplicate()
	add_child(ghost)
	
	#Xác định khoảng cách trượt (Nếu sang phải thì khung trượt sang trái (-1000) và ngược lại)
	var offset = -1000 if step > 0 else 1000
	#Tween cho khung cũ bay ra ngoài và mờ dần
	var tween_out = create_tween().set_parallel(true)
	tween_out.tween_property(ghost, "position:x", original_pos.x + offset, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween_out.tween_property(ghost, "modulate:a", 0.0, 0.4)
	tween_out.chain().tween_callback(ghost.queue_free)
	
	#Bước 2: Xử lý khung mới bay vào trong
	current_level = next_level
	update_ui(current_level) # Cập nhật chữ, %, background mới
	
	# Teleport cái nút thật ra hướng ngược lại (để chuẩn bị bay vào)
	play_button.position.x = original_pos.x - offset
	play_button.modulate.a = 0.0 # Bắt đầu từ trạng thái vô hình
	
	var tween_in = create_tween().set_parallel(true)
	tween_in.tween_property(play_button, "position:x", original_pos.x, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween_in.tween_property(play_button, "modulate:a", 1.0, 0.4)
	
	# Chờ hiệu ứng bay vào kết thúc thì mở khóa cho bấm tiếp
	await tween_in.finished
	is_animating = false
	
#Kết nối tín hiệu các nút
func _on_left_button_pressed() -> void:
	slide_animation(-1) #Đi lùi 1 bước
func _on_right_button_pressed() -> void:
	slide_animation(1) #Tiến lên 1 bước

func _on_level_1_button_pressed() -> void:
	if is_animating: return
	sfx_select.play()
	await get_tree().create_timer(0.7).timeout
	
	var target_scene = ""
	
	#Nếu là level 1 hoặc level 8 thì load scene cốt truyện trước thay vì load màn chơi
	if current_level == 1:
		target_scene = "res://StoryScene//story_lv_1.tscn"
	elif current_level == 8:
		target_scene = "res://StoryScene//story_lv_8_front.tscn"
	else:
		target_scene = "res://level_" + str(current_level) + ".tscn"
		
	TransitionManager.change_scene(target_scene)
	
#Nút back
func _on_back_button_pressed() -> void:
	TransitionManager.change_scene("res://home_screen.tscn")

#Nút mute
func _on_mute_button_pressed() -> void:
	#Lấy ID của kênh âm thanh tổng (master bus)
	var master_bus = AudioServer.get_bus_index("Master")
	#Kiểm tra xem kênh này có đang bị mute không
	var is_currently_muted = AudioServer.is_bus_mute(master_bus)
	#Đảo ngược trạng thái (đang bật thì tắt và ngược lại)
	AudioServer.set_bus_mute(master_bus, not is_currently_muted)
