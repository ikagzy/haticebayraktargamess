extends Button

func _ready():
	# Sinyali bağla
	pressed.connect(_on_pressed)
	# Kodla da garantiye alalım: Oyun durunca bu buton çalışmaya devam etsin
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_pressed():
	# 1. Mevcut pause ekranını bul ve sil (Daha spesifik hedefleme)
	var current_pause = get_tree().root.find_child("pausescreen", true, false)
	if current_pause:
		current_pause.queue_free()
	
	# 2. Ayarlar sahnesini yükle ve ekrana bas
	var settings_scene = load("res://oyunayarlari.tscn").instantiate()
	
	# 3. ÖNEMLİ: Ayarlar sahnesinin de donmaması için process_mode set et
	settings_scene.process_mode = Node.PROCESS_MODE_ALWAYS
	
	get_tree().root.add_child(settings_scene)
	
	# Fareyi sağlama al
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
