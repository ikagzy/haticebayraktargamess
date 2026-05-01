extends Area3D

@export var tuzak_kapisi: Node3D 

func _on_body_entered(body):
	if body is CharacterBody3D:
		if tuzak_kapisi and tuzak_kapisi.has_method("zorla_kapat_ve_kitle"):
			tuzak_kapisi.zorla_kapat_ve_kitle()
			
		await get_tree().create_timer(0.5).timeout
			
		if is_instance_valid(GorevArayuzu) and GorevArayuzu.has_method("altyazi_goster"):
			GorevArayuzu.altyazi_goster("Noluyor lan?!", 1.5)
			
		queue_free()
