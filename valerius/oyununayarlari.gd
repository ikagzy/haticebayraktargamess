extends Control

@onready var master_bus = AudioServer.get_bus_index("Master")

# DİKKAT: Bu satırı kendi sahne ağacındaki Label'ı sürükleyerek güncelle!
@onready var ses_yazisi = $seslabeli 

func _ready():
	# Oyun açıldığında GlobalAyarlar'daki kayıtlı sesi her yere uygula
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
	# Düz bir butonun basılma (pressed) sinyalini bu fonksiyona bağlaman yeterli
	GlobalAyarlar.toggle_fps()

func guncelle_ses_sistemi():
	# 1. Yazıyı güncelle (Hata vermemesi için kontrol ekledik)
	if is_instance_valid(ses_yazisi):
		ses_yazisi.text = "%" + str(GlobalAyarlar.ses_seviyesi)
	else:
		print("Hata: ses_yazisi (Label) bulunamadı! Yolunu kontrol et.")

	# 2. Sesi sisteme uygula
	var linear_val = GlobalAyarlar.ses_seviyesi / 100.0
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(linear_val))
	
	# 3. Sıfırsa tamamen sustur
	AudioServer.set_bus_mute(master_bus, GlobalAyarlar.ses_seviyesi <= 0)

