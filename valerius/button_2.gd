extends Button

@export var slot_name: String = "slot1"

func _ready():
	pressed.connect(_on_pressed)
	_update_button_text()

func _on_pressed():
	var desktop_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
	var save_path = desktop_path + "/Valerius_" + slot_name + ".dat"
	
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		get_tree().paused = false
		get_tree().change_scene_to_file(data["scene"])
		
		await get_tree().process_frame
		var player = get_tree().root.find_child("Player", true, false)
		if player:
			player.global_position = data["pos"]
			if "head" in player:
				player.head.rotation.y = data["rot"]
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		print("Kayıt bulunamadı!")

func _update_button_text():
	var desktop_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
	var save_path = desktop_path + "/Valerius_" + slot_name + ".dat"
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var data = file.get_var()
		file.close()
		text = data["save_date"]
	else:
		text = "Boş Slot"
