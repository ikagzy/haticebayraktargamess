extends Control

@onready var master_bus = AudioServer.get_bus_index("Master")
@onready var ses_yazisi = $seslabeli 

func _ready():
	print("--- DEBUG: Ayarlar Sahnesi Hazır ---")
	
	if has_node("ArtirButon"):
		if not $ArtirButon.pressed.is_connected(_on_artir_buton_pressed):
			$ArtirButon.pressed.connect(_on_artir_buton_pressed)
			print("DEBUG: ArtirButon kodla bağlandı.")
	
	if has_node("AzaltButon"):
		if not $AzaltButon.pressed.is_connected(_on_azalt_buton_pressed):
			$AzaltButon.pressed.connect(_on_azalt_buton_pressed)
			print("DEBUG: AzaltButon kodla bağlandı.")

	guncelle_ses_sistemi()

func _on_artir_buton_pressed():
	get_viewport().gui_release_focus()
	print("DEBUG: Artir tıklandı! Mevcut: ", GlobalAyarlar.ses_seviyesi)
	if GlobalAyarlar.ses_seviyesi < 100:
		GlobalAyarlar.ses_seviyesi += 10
		guncelle_ses_sistemi()

func _on_azalt_buton_pressed():
	get_viewport().gui_release_focus()
	print("DEBUG: Azalt tıklandı! Mevcut: ", GlobalAyarlar.ses_seviyesi)
	if GlobalAyarlar.ses_seviyesi > 0:
		GlobalAyarlar.ses_seviyesi -= 10
		guncelle_ses_sistemi()

func guncelle_ses_sistemi():
	if is_instance_valid(ses_yazisi):
		ses_yazisi.text = "%" + str(GlobalAyarlar.ses_seviyesi)
		print("DEBUG: Label güncellendi -> ", ses_yazisi.text)
	else:
		print("KRİTİK HATA: seslabeli düğümü bu yolda yok!")

	var linear_val = GlobalAyarlar.ses_seviyesi / 100.0
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(linear_val))
	AudioServer.set_bus_mute(master_bus, GlobalAyarlar.ses_seviyesi <= 0)

