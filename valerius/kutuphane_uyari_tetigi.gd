extends Area3D

@export var uyari_metni : String = "Kütüphane arkada kaldı... Geri dönmem gerek."
@export var yazi_suresi : float = 3.0

var zaten_tetiklendi = false

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and not zaten_tetiklendi:
		zaten_tetiklendi = true
		set_deferred("monitoring", false)
		uyariyi_goster()

func uyariyi_goster():
	if is_instance_valid(GorevArayuzu) and GorevArayuzu.has_method("altyazi_goster"):
		GorevArayuzu.altyazi_goster(uyari_metni, yazi_suresi)
