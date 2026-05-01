extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	var ga = get_node_or_null("/root/GlobalAyarlar")
	if ga:
		ga.toggle_fps()
	else:
		push_error("GlobalAyarlar bulunamadı! project.godot Autoload listesini kontrol et.")
