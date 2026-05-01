extends Button

@export var slot_name: String = "slot1" # Butonun Inspector panelinden slot1, slot2... yap

func _ready():
	pressed.connect(_on_pressed)
	# Eğer dosya varsa ismini tarih olarak güncelle
	_update_button_text()

func _on_pressed():
	var desktop_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
	var save_path = desktop_path + "/Valerius_" + slot_name + ".dat"
	
	var player = get_tree().root.find_child("Player", true, false)
	if player:
		var current_time = Time.get_datetime_string_from_system(false, true)
		var data = {
			"scene": get_tree().current_scene.scene_file_path,
			"pos": player.global_position,
			"rot": player.head.rotation.y if "head" in player else player.rotation.y,
			"save_date": current_time
		}
		
		var file = FileAccess.open(save_path, FileAccess.WRITE)
		file.store_var(data)
		file.close()
		
		text = current_time # Buton ismini değiştir
		print("Oyun Masaüstüne Kaydedildi: ", save_path)

func _update_button_text():
	var desktop_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
	var save_path = desktop_path + "/Valerius_" + slot_name + ".dat"
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var data = file.get_var()
		file.close()
		if data.has("save_date"):
			text = data["save_date"]
