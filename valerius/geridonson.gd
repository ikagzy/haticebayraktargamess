extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	# Tüm pause menülerini temizle
	get_tree().paused = false
	
	# Mevcut tüm sahneleri temizle (world ve pause menüleri)
	var root = get_tree().root
	for child in root.get_children():
		child.queue_free()
	
	# Main menu sahnesini yükle
	get_tree().change_scene_to_file("res://main_menu.tscn")
	
	# Fareyi görünür yap
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
