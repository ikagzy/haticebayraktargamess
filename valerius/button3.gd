extends Button

func _ready():
	pressed.connect(_on_pressed)
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_pressed():
	var current_pause = get_tree().root.find_child("pausescreen", true, false)
	if current_pause:
		current_pause.queue_free()
	
	var settings_scene = load("res://oyunayarlari.tscn").instantiate()
	
	settings_scene.process_mode = Node.PROCESS_MODE_ALWAYS
	
	get_tree().root.add_child(settings_scene)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
