extends Button

func _on_pressed():
	# Sadece sahne değiştir
	get_tree().change_scene_to_file("res://pausescreen.tscn")
	
	# Eski sahneyi temizle
	if owner:
		owner.queue_free()
