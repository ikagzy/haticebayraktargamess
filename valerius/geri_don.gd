extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	# Sadece bir önceki menüye döner, pause durumunu değiştirmez
	get_tree().change_scene_to_file("res://pausescreen.tscn")
