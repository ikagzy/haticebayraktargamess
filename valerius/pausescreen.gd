extends CanvasLayer

@onready var buton_kutusu = $ButonKutusu 
var asil_pozisyon_x: float = 0.0

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS 
	
	if buton_kutusu:
		asil_pozisyon_x = buton_kutusu.position.x

func _input(event):
	if event.is_action_pressed("pause"):
		var current_scene = get_tree().current_scene
		if current_scene and (current_scene.scene_file_path == "res://main_menu.tscn" or current_scene.name == "main_menu"):
			return
		
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause():
	var yeni_durum = !get_tree().paused
	get_tree().paused = yeni_durum
	
	if yeni_durum:
		visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		if is_instance_valid(GorevArayuzu):
			GorevArayuzu.visible = false
			
		if buton_kutusu:
			buton_kutusu.position.x = asil_pozisyon_x - 500 
			
			var tween = create_tween()
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			
			tween.tween_property(buton_kutusu, "position:x", asil_pozisyon_x, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			
	else:
		visible = false
		Input.call_deferred("set_mouse_mode", Input.MOUSE_MODE_CAPTURED)
		
		if is_instance_valid(GorevArayuzu):
			GorevArayuzu.visible = true

func _on_geridonus_pressed():
	print("Buton ile oyuna dönülüyor...")
	toggle_pause()

func _on_cikis_pressed():
	get_tree().paused = false
	
	self.visible = false 
	
	if is_instance_valid(GorevArayuzu):
		GorevArayuzu.visible = true
		
	get_tree().change_scene_to_file("res://main_menu.tscn")
