extends Button

func _ready():
	# Butona tıklandığında çıkış fonksiyonunu çalıştırır
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	# Oyunu tamamen kapatır
	get_tree().quit()
