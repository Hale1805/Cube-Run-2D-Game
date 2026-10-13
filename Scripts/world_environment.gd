extends WorldEnvironment

@export var toc_do_nhap_nhay: float = 5.475
@export var do_sang_toi_thieu: float = 0.6
@export var do_sang_binh_thuong: float = 1.0 # Mức 1.0 là độ sáng nguyên bản

var thoi_gian_troi: float = 0.0

func _process(delta):
	# Tích lũy thời gian
	thoi_gian_troi += delta * toc_do_nhap_nhay
	
	# Tính toán hệ số sóng (dao động mượt mà từ -1 đến 1)
	var song_sin = sin(thoi_gian_troi)
	
	# Đổi từ khoảng (-1 đến 1) sang khoảng (0 đến 1) để dễ tính toán
	var he_so = (song_sin + 1.0) / 2.0
	
	# TÁC ĐỘNG VÀO BRIGHTNESS (Độ sáng toàn màn hình)
	environment.adjustment_brightness = lerp(do_sang_toi_thieu, do_sang_binh_thuong, he_so)
