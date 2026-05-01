extends Node3D

@export_group("Kriz Ayarları")
@export var kriz_suresi: float = 4.0
@export var sarsinti_siddeti: float = 1.5 # Kafa sarsıntısının gücü (Eskiden 5.0 idi, çok düşürdük)

@export_group("Renk (Kan) Ayarları")
@export var kan_rengi: Color = Color(0.4, 0.0, 0.0) # Hafif koyu kırmızı
@export var max_saydamlik: float = 0.4 # Kırmızılığın en şiddetli anı (0 ile 1 arası, 1 = simsiyah kan)
@export var min_saydamlik: float = 0.05 # Kırmızılığın en zayıf anı

@export_group("Kriz Sonu Geçiş")
@export var kararma_hizi: float = 2.0 # Kriz bitince ekranın kararma süresi
@export var son_renk: Color = Color(0, 0, 0) # Kriz bittiğinde ekran ne renge bürünsün (Siyah)

func _ready() -> void:
	# Sensin animasyonunu başlat
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("karakter_cikis_animasyon")
	
	# Kamerayı bul (Özel sahnelerdeki kamera)
	var kamera = find_child("Camera*3D", true, false)
	if not kamera:
		kamera = get_viewport().get_camera_3d()

	# ColorRect'i bul (Eğer sen eklediysen bulur, yoksa kendi yaratır)
	var color_rect = find_child("ColorRect", true, false)
	
	# Kafa travması efektini tetikle!
	_travma_gecir(kamera, color_rect)

func _travma_gecir(kam: Camera3D, cr: ColorRect) -> void:
	# === 1. KANLI EKRAN / FLAŞ EFEKTİ (Kalp atışı gibi) ===
	if cr:
		# Rengi Color olarak ata, alpha 0 (saydam) başlasın
		cr.color = Color(kan_rengi.r, kan_rengi.g, kan_rengi.b, 0.0) 
		var renk_tween = create_tween().set_loops() # Sonsuz döngü (kriz boyunca)
		
		# Nabız atışı gibi azalıp çoğalma - Saydamlıkları min_saydamlik ve max_saydamlik üzerinden alıyor
		renk_tween.tween_property(cr, "color:a", max_saydamlik, 0.3).set_trans(Tween.TRANS_SINE)
		renk_tween.tween_property(cr, "color:a", min_saydamlik, 0.4).set_trans(Tween.TRANS_SINE)
		renk_tween.tween_property(cr, "color:a", max_saydamlik * 0.8, 0.2).set_trans(Tween.TRANS_EXPO) # İkinci ufak atış
		renk_tween.tween_property(cr, "color:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
		
		# Kriz bitince temizlemesi için:
		get_tree().create_timer(kriz_suresi).timeout.connect(func():
			if renk_tween.is_valid(): renk_tween.kill()
			
			# Sadece alpha'yı değil, rengi bütünüyle siyah falan yapabiliriz
			var bitis_tween = create_tween()
			bitis_tween.tween_property(cr, "color", Color(son_renk.r, son_renk.g, son_renk.b, 1.0), kararma_hizi) 
		)

	# === 2. HAFİF KAFA SALLANMASI (Kamera Titremesi) ===
	if kam:
		var original_rot_z = kam.rotation.z
		var shake_tween = create_tween().set_loops(kriz_suresi * 4) # Süre * saniyede 4 titreme (Daha Yavaş)
		
		# Sağa Çarp
		shake_tween.tween_property(kam, "rotation:z", 
			original_rot_z + deg_to_rad(randf_range(sarsinti_siddeti/1.5, sarsinti_siddeti)), 0.1)\
			.set_trans(Tween.TRANS_SINE) # BOUNCE yerine SINE kullanarak yumuşattık
		
		# Sola Çarp
		shake_tween.tween_property(kam, "rotation:z", 
			original_rot_z - deg_to_rad(randf_range(sarsinti_siddeti/1.5, sarsinti_siddeti)), 0.1)\
			.set_trans(Tween.TRANS_SINE)

		# Normalleşme (Kriz bittiğinde dur)
		await get_tree().create_timer(kriz_suresi).timeout
		if shake_tween.is_valid(): 
			shake_tween.kill()
		
		var duz_tween = create_tween()
		duz_tween.tween_property(kam, "rotation:z", original_rot_z, 0.5)\
			.set_trans(Tween.TRANS_ELASTIC)

	# İsteğe bağlı: Kriz anında altyazı eklenebilir
	if is_instance_valid(GorevArayuzu) and GorevArayuzu.has_method("altyazi_goster"):
		GorevArayuzu.altyazi_goster("BAŞIM ÇATLIYOR", 3.0)

	# Animasyon veya kriz bittiğinde ana sahneye (veya oda sahnesine) geçmek istersen:
	var toplam_bekleme = kriz_suresi + kararma_hizi + 0.5
	await get_tree().create_timer(toplam_bekleme).timeout
	if is_instance_valid(get_node_or_null("/root/SahneGecisi")):
		SahneGecisi.gecis_yap("res://oda.tscn")
	else:
		get_tree().change_scene_to_file("res://oda.tscn")
