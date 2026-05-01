extends Control

@onready var master_bus = AudioServer.get_bus_index("Master")

func _on_h_slider_value_changed(value: float):
	get_viewport().gui_release_focus()
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	
	if value == 0:
		AudioServer.set_bus_mute(master_bus, true)
	else:
		AudioServer.set_bus_mute(master_bus, false)

