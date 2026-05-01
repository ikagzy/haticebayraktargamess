extends Node

var current_pause_menu = null

# Menü açmak için kullan
func open_menu(menu_path: String):
	# Eğer zaten bir menü varsa kapat
	if current_pause_menu:
		current_pause_menu.queue_free()
	
	# Yeni menüyü yükle
	var menu = load(menu_path).instantiate()
	get_tree().root.add_child(menu)
	current_pause_menu = menu
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Tüm menüleri kapatıp oyuna dön
func close_all_menus():
	if current_pause_menu:
		current_pause_menu.queue_free()
		current_pause_menu = null
	
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Main menu'ye dön
func go_to_main_menu():
	# Tüm menüleri kapat
	close_all_menus()
	
	# World sahnesini temizle
	var world = get_tree().root.get_node("world")
	if world:
		world.queue_free()
	
	# Main menu'ye geç
	get_tree().change_scene_to_file("res://main_menu.tscn")
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
