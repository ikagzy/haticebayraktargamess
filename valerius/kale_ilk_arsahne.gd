extends Node

# ============================================================
# KALE ILK ARA SAHNE
# 1. Sahne açılır açılmaz AnimationPlayer "kale_arasahne"yi oynatır
# 2. Animasyon bitince altyazı çıkar: "Bunların olmasının imkânı yok"
# 3. Altyazı bittikten sonra kale.tscn'e geçilir
# ============================================================

var gecis_yapildi = false

func _ready():
	# AnimationPlayer'ı bul ve hemen oynat
	var anim_player = find_child("AnimationPlayer", true, false)
	
	if anim_player and anim_player.has_animation("kale_arasahne"):
		anim_player.play("kale_arasahne")
		# Animasyonun bitmesini bekle
		await anim_player.animation_finished
	else:
		# AnimationPlayer veya animasyon bulunamadıysa hata ver ve 2 sn bekle
		push_warning("kale_ilk_arsahne: 'kale_arasahne' animasyonu bulunamadi! AnimationPlayer dugum adini kontrol et.")
		await get_tree().create_timer(2.0).timeout
	
	# Animasyon bitti, simdi altyazi goster
	if is_instance_valid(GorevArayuzu) and GorevArayuzu.has_method("altyazi_goster"):
		GorevArayuzu.altyazi_goster("Marcus: \"Bunlarin olmasinin imkani yok...\"", 3.5)
	
	# Altyazi suresi kadar bekle, sonra kale.tscn'e gec
	await get_tree().create_timer(3.5).timeout
	
	if not gecis_yapildi:
		gecis_yapildi = true
		get_tree().change_scene_to_file("res://kale.tscn")
