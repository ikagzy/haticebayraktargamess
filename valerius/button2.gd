extends CanvasLayer

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	var yeni_durum = !get_tree().paused
	get_tree().paused = yeni_durum
	visible = yeni_durum
	
	if yeni_durum:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_geridonu_pressed():
	toggle_pause()

func _on_cikis_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
