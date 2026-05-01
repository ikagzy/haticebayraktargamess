extends Button

func _ready():
	pressed.connect(_on_pressed)
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_pressed():
	get_tree().change_scene_to_file("res://pausescreen.tscn")
	queue_free()
