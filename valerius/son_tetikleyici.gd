extends Area3D

@export var kazanilacak_son: int = 1 # Hangi son açılacak (1, 2, 3, 4...)

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is CharacterBody3D:
		if has_node("/root/GlobalSonlar"):
			GlobalSonlar.sonu_ac(kazanilacak_son)
		get_tree().change_scene_to_file("res://sonlar.tscn")
