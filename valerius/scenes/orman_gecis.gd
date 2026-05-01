extends Area3D

func _on_body_entered(body: Node3D) -> void:
	# Eğer giren karakter Player ise (grup veya isim kontrolü)
	if body.is_in_group("Player") or body.name == "CharacterBody3D" or "Player" in body.name:
		if is_instance_valid(get_node_or_null("/root/SahneGecisi")):
			SahneGecisi.gecis_yap("res://scenes/world_arasahne.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/world_arasahne.tscn")
