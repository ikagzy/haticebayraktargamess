extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 1. Animasyonu başlat
	if has_node("AnimationPlayer"):
		var anim = $AnimationPlayer
		anim.play("uyku")
		
		# 2. BİTMESİNİ BEKLE
		await anim.animation_finished
		
	# 3. KABUS BAYRAĞINI AKTİFLEŞTİR VE ODAYA GERİ DÖN
	if is_instance_valid(OyunVerisi):
		OyunVerisi.kabus_gordu = true
		
	if is_instance_valid(get_node_or_null("/root/SahneGecisi")):
		SahneGecisi.gecis_yap("res://oda.tscn")
	else:
		get_tree().change_scene_to_file("res://oda.tscn")
