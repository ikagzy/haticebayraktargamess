extends Node3D

func _ready() -> void:
	# 1. Animasyonu başlat
	$AnimationPlayer.play("odacutscene")
	
	# 2. Kodun geri kalanını çalıştırmadan önce animasyonun BİTMESİNİ BEKLE
	await $AnimationPlayer.animation_finished
	
	# 3. Animasyon bittiği an sahneyi değiştir
	get_tree().change_scene_to_file("res://oda.tscn")


# _process metodu kaldırıldı, çünkü kullanılmıyor ve debugger uyarısı veriyor.
