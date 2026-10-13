extends CanvasLayer

@export var current_level: int = 1 #Chỉnh số này trong inspector của từng màn để game biết mà lưu lại % cho từng màn chơi riêng
@onready var pause_menu = $PauseMenu
@onready var pause_button = $PauseButton
@onready var sfx_button = $SFX_Button
@onready var level_complete_menu = $LevelCompleteMenu
@onready var win_panel = $LevelCompleteMenu/Panel
@onready var sfx_win = $SFX_Win
@onready var progress_bar = $HBoxContainer/ProgressBar
@onready var progress_label = $HBoxContainer/ProgressLabel
#Khai báo đường dẫn tới Player và Finish line
#Dấu ../ nghĩa là thoát khỏi UILayer 1 bậc để tìm các node khác
@onready var player = $"../Player"
@onready var finish_line = $"../finish_line"

@onready var time_label = $LevelCompleteMenu/Panel/TimeLabel
@onready var attempt_label = $LevelCompleteMenu/Panel/AttemptLabel

#Biến lưu tọa đồ bắt đầu
var start_x: float

# Khi bấm nút tạm dừng ở góc màn hình
func _on_pause_button_pressed() -> void:
	get_tree().paused = true # Lệnh này làm mọi thứ trong game đứng im
	pause_menu.show()        # Hiện cái bảng menu lên
	pause_button.hide()

func _on_resume_pressed() -> void:
	get_tree().paused = false # Ngược lại lệnh pause true, khiến game tiếp tục chạy
	pause_menu.hide()         # Cất bảng menu đi
	pause_button.show()

func _on_reset_pressed() -> void:
	get_tree().paused = false # khiến game tiếp tục chạy
	get_tree().reload_current_scene()  #Nhưng ở đây ta reload lại màn chơi

func _on_exit_pressed() -> void:
	sfx_button.play()
	await get_tree().create_timer(0.7).timeout
	get_tree().paused = false
	pause_menu.hide()
	#Báo cho Global biết mình vừa thoát ra từ màn nào
	Global.last_played_level = current_level
	#Reset biến đếm thời gian và attempt khi thoát
	Global.reset_level_stats()
	TransitionManager.change_scene("res://level_menu.tscn")

func show_win_screen() -> void:
	# 1. Cập nhật label text trước khi hiển thị
	var minutes = int(Global.level_time) / 60
	var seconds = int(Global.level_time) % 60
	var msec = int((Global.level_time - int(Global.level_time)) * 100)
	
	time_label.text = "TIME: %02d:%02d.%02d" % [minutes, seconds, msec]
	attempt_label.text = "ATTEMPTS: " + str(Global.level_attempts)
	
	# 2. Phát âm thanh
	sfx_win.play()
	# 3. Hẹn giờ, sau 1.3s là hiện menu kết thúc
	await get_tree().create_timer(1.3).timeout
	# 4. Hiện Menu (Lúc này Panel bên trong nó vẫn đang tàng hình ở y = -600)
	level_complete_menu.show()
	# 5. Kích hoạt Tween để thả rơi Panel
	var tween = create_tween()
	# Lấy chiều cao màn hình thực tế trừ đi chiều cao của panel, rồi chia 2
	var target_y = (get_viewport().get_visible_rect().size.y - win_panel.size.y) / 2.0
	# TRANS_BOUNCE tạo hiệu ứng rơi đập xuống đất nảy lên
	tween.tween_property(win_panel, "position:y", target_y, 0.8).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
func _ready() -> void:
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	
	#Lưu lại vị trí x của người chơi ngay lúc vừa vào game
	if is_instance_valid(player):
		start_x = player.global_position.x

#Hàm process chạy liên tục mỗi khung hình để cập nhật thanh tải
func _process(delta: float) -> void:
	if not get_tree().paused and not level_complete_menu.visible:
		Global.level_time += delta
	#Kiểm tra player và finish line còn tồn tại không
	if is_instance_valid(player) and is_instance_valid(finish_line):
		#Tính toán quãng đường
		var current_distance = player.global_position.x - start_x
		var total_distance = finish_line.global_position.x - start_x
		
		if total_distance > 0:
			var percentage = clamp((current_distance / total_distance) * 100, 0.0, 100.0)
			#Lệnh clamp giúp ép con số luôn luôn nằm gọn trong khoảng từ 0 đến 100
			progress_bar.value = percentage
			#Ép kiểu percentage sang sô nguyên, rồi đổi thành chuỗi và ghép thêm dấu %
			progress_label.text = str(int(percentage)) + "%"
			
			#Chỉ lưu vào ổ cứng khi điểm hiện tại lớn hơn kỷ lục cũ
			if percentage > Global.level_progress[current_level]:
				Global.level_progress[current_level] = percentage
				Global.save_data()

# Hàm này CHỈ kết nối với nút Exit của bảng LEVEL COMPLETE MENU
func _on_level_complete_exit_pressed() -> void:
	sfx_button.play()
	await get_tree().create_timer(0.7).timeout
	get_tree().paused = false
	
	Global.last_played_level = current_level
	Global.reset_level_stats()
	
	# Chuyển sang kết thúc story khi win level 8
	if current_level == 8:
		TransitionManager.change_scene("res://StoryScene//story_lv_8_after.tscn")
	else:
		TransitionManager.change_scene("res://level_menu.tscn")
