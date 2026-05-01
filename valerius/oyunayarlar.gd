extends Button  # "Geri dön" butonu için

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	# 1. Bu ayarlar sahnesini kapat
	get_tree().paused = false  # gerekliyse
	get_parent().queue_free()  # ayarlar sahnesini sil
	
	# 2. Pause menüsünü geri aç
	var pause_scene = preload("res://pausescreen.tscn").instantiate()
	get_tree().root.add_child(pause_scene)
	
	# 3. Fareyi görünür yap (pause menüsünde kalacağız)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
