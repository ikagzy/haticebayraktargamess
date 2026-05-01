extends Button

func _ready():
	pressed.connect(_on_pressed)
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_pressed():
	# Direkt pausescreen sahnesine dön, pause durumu KORUNSUN
	# (çünkü hala pause menüsündeyiz)
	get_tree().change_scene_to_file("res://pausescreen.tscn")
	# Eski sahneyi temizle
	queue_free()
