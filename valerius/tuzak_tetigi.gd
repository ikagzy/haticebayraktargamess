extends Area3D

@export var tuzak_kapisi: Node3D 

func _on_body_entered(body):
	if body is CharacterBody3D:
		# 1. Kapıyı ANINDA kapat ve kilitle
		if tuzak_kapisi and tuzak_kapisi.has_method("zorla_kapat_ve_kitle"):
			tuzak_kapisi.zorla_kapat_ve_kitle()
			
		# 2. ŞOK ETKİSİ İÇİN SİHİRLİ BEKLEME (1.5 Saniye Delay)
		# Kod burada 1.5 saniye duraklayacak, oyuncu arkasına dönecek
		await get_tree().create_timer(0.5).timeout
			
		# 3. Süre dolunca o efsanevi altyazıyı ekrana bas!
		if is_instance_valid(GorevArayuzu) and GorevArayuzu.has_method("altyazi_goster"):
			GorevArayuzu.altyazi_goster("Noluyor lan?!", 1.5)
			
		# 4. Tuzak kendini yok etsin
		queue_free()
