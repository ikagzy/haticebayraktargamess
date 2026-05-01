extends Area3D

@export var uyari_metni : String = "Kütüphanenin ışığı neden açık?"
@export var yazi_suresi : float = 2.0

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" or body is CharacterBody3D:
		yaziyi_tetikle()

func yaziyi_tetikle():
	set_deferred("monitoring", false)
	
	if is_instance_valid(GorevArayuzu):
		if GorevArayuzu.has_method("altyazi_goster"):
			GorevArayuzu.altyazi_goster(uyari_metni, yazi_suresi)
		
