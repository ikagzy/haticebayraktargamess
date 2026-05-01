extends Control

@onready var master_bus = AudioServer.get_bus_index("Master")

@onready var ses_yazisi = $Panel/seslabeli
@onready var slider = $Panel/HSlider

func _ready():
	if slider == null:
		print("HATA: Slider bulunamadı! Node yolunu kontrol et.")
		
		var all_sliders = get_tree().get_nodes_in_group("volume_slider")
		if all_sliders.size() > 0:
			slider = all_sliders[0]
			print("Alternatif slider bulundu: ", slider.name)
		return
	
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 1
	slider.value = 70
	
	print("Slider başarıyla bağlandı: ", slider.name)
	print("Slider min_value: ", slider.min_value)
	
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		slider.value = config.get_value("Audio", "volume", 70.0)
	
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
	
	var config = ConfigFile.new()
	config.set_value("Audio", "volume", value)
	config.save("user://settings.cfg")

