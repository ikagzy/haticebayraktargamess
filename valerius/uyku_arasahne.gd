extends Node3D


func _ready() -> void:
	if has_node("AnimationPlayer"):
		var anim = $AnimationPlayer
		anim.play("uyku")
		
		await anim.animation_finished
		
	if is_instance_valid(OyunVerisi):
		OyunVerisi.kabus_gordu = true
		
	if is_instance_valid(get_node_or_null("/root/SahneGecisi")):
		SahneGecisi.gecis_yap("res://oda.tscn")
	else:
		get_tree().change_scene_to_file("res://oda.tscn")
