extends Control

@onready var master_bus = AudioServer.get_bus_index("Master")

@onready var ses_yazisi = $seslabeli 

func _ready():
	guncelle_ses_sistemi()

func _on_artir_buton_pressed():
	get_viewport().gui_release_focus()
	if GlobalAyarlar.ses_seviyesi < 100:
		GlobalAyarlar.ses_seviyesi += 10
		guncelle_ses_sistemi()

func _on_azalt_buton_pressed():
	get_viewport().gui_release_focus()
	if GlobalAyarlar.ses_seviyesi > 0:
		GlobalAyarlar.ses_seviyesi -= 10
		guncelle_ses_sistemi()

func _on_fps_buton_pressed():
	get_viewport().gui_release_focus()
	GlobalAyarlar.toggle_fps()

func guncelle_ses_sistemi():
	if is_instance_valid(ses_yazisi):
		ses_yazisi.text = "%" + str(GlobalAyarlar.ses_seviyesi)
	else:
		print("Hata: ses_yazisi (Label) bulunamadı! Yolunu kontrol et.")

	var linear_val = GlobalAyarlar.ses_seviyesi / 100.0
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(linear_val))
	
	AudioServer.set_bus_mute(master_bus, GlobalAyarlar.ses_seviyesi <= 0)

