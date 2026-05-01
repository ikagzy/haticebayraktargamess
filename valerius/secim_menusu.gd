extends CanvasLayer


func _on_button_pressed():
	self.visible = false 
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false 
	
	if is_instance_valid(GorevArayuzu):
		GorevArayuzu.altyazi_goster("... Zaman elbet seni de alıp gidecek ...", 4.0)
		GorevArayuzu._on_gorev_guncellendi("Görev: Kütüphaneyi araştır")

	
	OyunVerisi.kapi_acildi = true

func _on_button_2_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if GlobalSonlar.son1_acildi:
		if is_instance_valid(GorevArayuzu):
			GorevArayuzu.altyazi_goster("... Zamandan kaçamazsın ...", 3.0)
		
		self.visible = false 
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_tree().paused = false 
		
		await get_tree().create_timer(1.0).timeout
		
		if is_instance_valid(GorevArayuzu):
			GorevArayuzu._on_gorev_guncellendi("Görev: Kütüphaneyi araştır")
		
		OyunVerisi.kapi_acildi = true
		get_tree().change_scene_to_file("res://kutuphane_ara_sahne.tscn")
	else:
		self.visible = false
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		if is_instance_valid(OyunVerisi):
			OyunVerisi.vazgecti = true
		
		get_tree().change_scene_to_file("res://oda.tscn")
