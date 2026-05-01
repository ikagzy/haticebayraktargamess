extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	get_tree().paused = false
	get_parent().queue_free()
	
	var pause_scene = preload("res://pausescreen.tscn").instantiate()
	get_tree().root.add_child(pause_scene)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
