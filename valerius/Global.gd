extends Node

var current_pause_menu = null

func open_menu(menu_path: String):
	if current_pause_menu:
		current_pause_menu.queue_free()
	
	var menu = load(menu_path).instantiate()
	get_tree().root.add_child(menu)
	current_pause_menu = menu
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close_all_menus():
	if current_pause_menu:
		current_pause_menu.queue_free()
		current_pause_menu = null
	
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func go_to_main_menu():
	close_all_menus()
	
	var world = get_tree().root.get_node("world")
	if world:
		world.queue_free()
	
	get_tree().change_scene_to_file("res://main_menu.tscn")
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
