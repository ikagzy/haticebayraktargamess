extends Control

@onready var master_bus = AudioServer.get_bus_index("Master")

# Doğru yolları kontrol et (sahnenin yapısına göre değiştir)
@onready var ses_yazisi = $Panel/seslabeli  # veya $VBoxContainer/seslabeli
@onready var slider = $Panel/HSlider         # veya $VBoxContainer/HSlider

func _ready():
	# ÖNCE KONTROL ET: slider null mu?
	if slider == null:
		print("HATA: Slider bulunamadı! Node yolunu kontrol et.")
		
		# Alternatif olarak tüm HSLider'ları bul
		var all_sliders = get_tree().get_nodes_in_group("volume_slider")
		if all_sliders.size() > 0:
			slider = all_sliders[0]
			print("Alternatif slider bulundu: ", slider.name)
		return
	
	# Slider ayarları
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 1
	slider.value = 70  # Başlangıç değeri
	
	# DEBUG: Slider bilgilerini yazdır
	print("Slider başarıyla bağlandı: ", slider.name)
	print("Slider min_value: ", slider.min_value)
	
	# Kayıtlı sesi yükle
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:  # DÜZELT: 0K değil OK
		slider.value = config.get_value("Audio", "volume", 70.0)
	
	# İlk ses ayarını uygula
	_on_h_slider_value_changed(slider.value)

func _on_h_slider_value_changed(value):
	get_viewport().gui_release_focus()
	if ses_yazisi != null:
		ses_yazisi.text = "%" + str(int(value))
	else:
		print("UYARI: ses_yazisi null!")
	
	var linear_val = value / 100.0
	var db_value = linear_to_db(linear_val)
	AudioServer.set_bus_volume_db(master_bus, db_value)
	
	if linear_val <= 0.001:
		AudioServer.set_bus_mute(master_bus, true)
	else:
		AudioServer.set_bus_mute(master_bus, false)
	
	# Kaydet
	var config = ConfigFile.new()
	config.set_value("Audio", "volume", value)
	config.save("user://settings.cfg")

