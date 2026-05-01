extends Button

func _ready():
	# Butona tıklandığında, bu scriptteki '_on_pressed' fonksiyonunu çağır
	pressed.connect(_on_pressed)

func _on_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
