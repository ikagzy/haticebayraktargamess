extends Button

func _on_pressed():
	get_tree().change_scene_to_file("res://pausescreen.tscn")
	
	if owner:
		owner.queue_free()
