extends Area3D


@onready var secim_menusu = get_node_or_null("../SecimMenusu")

func _ready():
	pass

func _on_body_entered(body):
	if not (body is CharacterBody3D or body.is_in_group("Player")):
		return
		
	if OyunVerisi.get("kapi_acildi") == false:
		if is_instance_valid(secim_menusu):
			secim_menusu.visible = true 
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().paused = true 

func _on_body_exited(body):
	if (body is CharacterBody3D or body.is_in_group("Player")):
		if is_instance_valid(secim_menusu) and not OyunVerisi.get("kapi_acildi"):
			secim_menusu.visible = false 
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
