extends Button

func _ready():
	pressed.connect(_on_pressed)
	pivot_offset = size / 2

func _on_pressed():
	# ÖNCE mevcut pausescreen'i sil
	get_parent().get_parent().queue_free()  # veya doğrudan sahneyi bul
	# SONRA yeni sahneyi ekle
	get_tree().change_scene_to_file("pausekayit.tscn")
