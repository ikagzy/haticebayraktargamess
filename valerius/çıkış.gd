extends Button

func _ready():
	pivot_offset = size / 2
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	pressed.connect(_on_cikis_pressed) 

func _on_mouse_entered():
	if has_node("SesHover"):
		$SesHover.play()
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate", Color(0.8, 0.8, 0.8), 0.1)
	
	tween.tween_method(renk_doldur, 0.0, 1.0, 0.2)

func _on_mouse_exited():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.1)
	
	tween.tween_method(renk_doldur, 1.0, 0.0, 0.2)

func _on_cikis_pressed():
	if has_node("SesTikla"):
		$SesTikla.play()
	
	scale = Vector2(0.9, 0.9)
	
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()

func renk_doldur(alpha_degeri: float):
	var guncel_renk = Color(1, 1, 1, alpha_degeri) 
	
	add_theme_color_override("font_color", guncel_renk)
	add_theme_color_override("font_hover_color", guncel_renk)
	add_theme_color_override("font_focus_color", guncel_renk)
	add_theme_color_override("font_pressed_color", guncel_renk)
