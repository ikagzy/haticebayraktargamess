extends Button

func _ready():
	pressed.connect(_on_pressed)
	pivot_offset = size / 2

func _on_pressed():
	get_parent().get_parent().queue_free()
	get_tree().change_scene_to_file("pausekayit.tscn")
