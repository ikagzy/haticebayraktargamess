extends Control

@onready var master_bus = AudioServer.get_bus_index("Master")
@onready var slider = $HSlider

var is_dragging = false

func _ready():
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 1
	slider.value = 70
	
	var current_db = AudioServer.get_bus_volume_db(master_bus)
	var current_percent = db_to_linear(current_db) * 100
	slider.value = current_percent

func _on_h_slider_drag_started():
	is_dragging = true

func _on_h_slider_drag_ended(_value_changed):
	is_dragging = false
	_update_volume()

func _on_h_slider_value_changed(value):
	if not is_dragging:
		_update_volume()

func _update_volume():
	var percent = slider.value / 100.0
	
	var db_value = linear_to_db(percent)
	AudioServer.set_bus_volume_db(master_bus, db_value)
	
	AudioServer.set_bus_mute(master_bus, percent <= 0.01)
