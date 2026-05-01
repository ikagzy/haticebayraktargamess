extends Area3D

# Altyazıda ne yazmasını istiyorsan Inspector'dan değiştirebilirsin
@export var uyari_metni : String = "Kütüphanenin ışığı neden açık?"
@export var yazi_suresi : float = 2.0

func _on_body_entered(body: Node3D) -> void:
	# Eğer bu alana giren şey bizim karakterimizse (Player veya CharacterBody3D)
	if body.name == "Player" or body is CharacterBody3D:
		yaziyi_tetikle()

func yaziyi_tetikle():
	# Yazıyı sadece bir kere göstermek için tetikleyiciyi anında kapatıyoruz
	set_deferred("monitoring", false)
	
	# Senin karakter scriptinde kullandığımız GorevArayuzu sistemini çağırıyoruz
	if is_instance_valid(GorevArayuzu):
		if GorevArayuzu.has_method("altyazi_goster"):
			GorevArayuzu.altyazi_goster(uyari_metni, yazi_suresi)
		
		# İstersen görevi de güncelleyebilirsin (Başındaki # işaretini silersen çalışır)
		# GorevArayuzu._on_gorev_guncellendi("Görev: İlerlemeye Devam Et")
