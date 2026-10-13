extends Node
var level_progress: Dictionary = {
	1: 0.0,
	2: 0.0,
	3: 0.0,
	4: 0.0,
	5: 0.0,
	6: 0.0,
	7: 0.0,
	8: 0.0
}

# Biến này sẽ nhớ xem người chơi vừa ở màn nào trước khi ra Menu
var last_played_level: int = 1

#Biến thời gian và số lần thử
var level_time: float = 0.0
var level_attempts: int = 1

# Khai báo đường dẫn lưu file. 
const SAVE_PATH = "user://savegame.cfg"

# Hàm này sẽ tự động chạy ngay khi người chơi vừa click đúp mở game lên
func _ready() -> void:
	load_data()

# Hàm lưu dữ liệu vào ổ cứng
func save_data() -> void:
	var config = ConfigFile.new()
	# Tạo một mục tên là "Progress", lưu biến all_levels vào đó
	config.set_value("Progress", "all_levels", level_progress)
	config.save(SAVE_PATH)

# Hàm đọc dữ liệu từ ổ cứng
func load_data() -> void:
	var config = ConfigFile.new()
	# Kiểm tra xem file save đã tồn tại trong máy chưa
	if config.load(SAVE_PATH) == OK:
		# Nếu có, lấy con số đó ra. Nếu không tìm thấy, mặc định trả về 0.0
		level_progress = config.get_value("Progress", "all_levels", level_progress)

#Hàm reset lại thời gian và số lần thử khi thoát level
func reset_level_stats() -> void:
	level_time = 0.0
	level_attempts = 1
