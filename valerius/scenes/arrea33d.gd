extends Area3D

func _on_body_entered(body):
	if body.name == "CharacterBo":
		var sistem = get_tree().root.find_child("gorevsistemi", true, false)
		
		if sistem:
			sistem.gorev_tamamla()
			queue_free()
