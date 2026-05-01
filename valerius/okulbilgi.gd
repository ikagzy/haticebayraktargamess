extends Node3D

@onready var anahtar = $Anahtar_1
@onready var spawn_noktalari = [$Spawn1, $Spawn2, $Spawn3]

func _ready():
	if OyunVerisi.get("baslangic_repligi_calindi") == false or OyunVerisi.get("baslangic_repligi_calindi") == null:
		
		OyunVerisi.baslangic_repligi_calindi = true
		
		if is_instance_valid(GorevArayuzu):
			if GorevArayuzu.has_method("ekrana_bilgi_bas"):
				GorevArayuzu.ekrana_bilgi_bas("[Shift] ile koşabilirsin.\nAncak staminana dikkat et,\nyorulursan yavaşlarsın!")
				
			await get_tree().create_timer(1.0).timeout
			
			if GorevArayuzu.has_method("altyazi_goster"):
				GorevArayuzu.altyazi_goster("Koridor da bayağı karanlıkmış...", 1.2)
	
	randomize()
	var secilen_nokta = spawn_noktalari.pick_random()
	if anahtar and secilen_nokta:
		anahtar.global_position = secilen_nokta.global_position
		print("Anahtar şu noktaya ışınlandı: ", secilen_nokta.name)
