extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	get_tree().paused = false
	
	var root = get_tree().root
	for child in root.get_children():
		child.queue_free()
	
	get_tree().change_scene_to_file("res://main_menu.tscn")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
