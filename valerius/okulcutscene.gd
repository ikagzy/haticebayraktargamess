extends Node3D

func _ready() -> void:
	$AnimationPlayer.play("Cutscene")
	
	await $AnimationPlayer.animation_finished
	
	get_tree().change_scene_to_file("res://odacutscene.tscn")
