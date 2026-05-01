extends Node3D

func _ready():
	# Yüzükten gelen altyazı: kale açılır açılmaz 0.5 saniyede hemen çıksın
	await get_tree().create_timer(0.5).timeout
	
	if is_instance_valid(GorevArayuzu) and GorevArayuzu.has_method("altyazi_goster"):
		GorevArayuzu.altyazi_goster("Marcus: \"Bunların olmasının imkânı yok...\"", 4.0)
