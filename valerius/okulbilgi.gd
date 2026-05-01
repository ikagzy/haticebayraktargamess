extends Node3D

@onready var anahtar = $Anahtar_1 # Sahnedeki anahtarın adı
@onready var spawn_noktalari = [$Spawn1, $Spawn2, $Spawn3] # Marker3D noktaların

func _ready():
	# === 1. GİRİŞ BİLGİLERİ VE REPLİK (SADECE BİR KERE ÇALIŞIR) ===
	if OyunVerisi.get("baslangic_repligi_calindi") == false or OyunVerisi.get("baslangic_repligi_calindi") == null:
		
		OyunVerisi.baslangic_repligi_calindi = true
		
		if is_instance_valid(GorevArayuzu):
			if GorevArayuzu.has_method("ekrana_bilgi_bas"):
				GorevArayuzu.ekrana_bilgi_bas("[Shift] ile koşabilirsin.\nAncak staminana dikkat et,\nyorulursan yavaşlarsın!")
				
			await get_tree().create_timer(1.0).timeout
			
			if GorevArayuzu.has_method("altyazi_goster"):
				GorevArayuzu.altyazi_goster("Koridor da bayağı karanlıkmış...", 1.2)
	
	# === 2. ANAHTARI GİZLİCE RASTGELE BİR NOKTAYA SAKLA (BOZULMADI) ===
	randomize()
	var secilen_nokta = spawn_noktalari.pick_random()
	if anahtar and secilen_nokta:
		anahtar.global_position = secilen_nokta.global_position
		print("Anahtar şu noktaya ışınlandı: ", secilen_nokta.name)
		# Not: Görev burada başlamıyor, oyuncu kapıyı zorlayınca başlayacak.
