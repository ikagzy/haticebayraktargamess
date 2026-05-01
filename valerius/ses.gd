extends Control

# AudioServer üzerinden ana ses kanalının (Master) numarasını alıyoruz
@onready var master_bus = AudioServer.get_bus_index("Master")

func _on_h_slider_value_changed(value: float):
	get_viewport().gui_release_focus()
	# Godot sesleri doğrusal değil, logaritmik (dB) olarak işler.
	# linear_to_db fonksiyonu sayesinde 0-1 arası değeri doğru duyulacak sese çeviririz.
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	
	# Eğer slider en sola (0) gelirse sesi tamamen kapat (Mute)
	if value == 0:
		AudioServer.set_bus_mute(master_bus, true)
	else:
		AudioServer.set_bus_mute(master_bus, false)

