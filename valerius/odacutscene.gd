extends Node3D

func _ready() -> void:
	$AnimationPlayer.play("odacutscene")
	
	await $AnimationPlayer.animation_finished
	
	get_tree().change_scene_to_file("res://oda.tscn")
