extends Button

func _ready():
	pivot_offset = size / 2
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited) 
	pressed.connect(_on_pressed)

func _on_mouse_entered():
	if self.disabled: return 
	if has_node("SesHover"):
		$SesHover.play()
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate", Color(0.8, 0.8, 0.8), 0.1)
	tween.tween_method(renk_doldur, 0.0, 1.0, 0.2)

func _on_mouse_exited():
	if self.disabled: return 
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.1)
	tween.tween_method(renk_doldur, 1.0, 0.0, 0.2)

func _on_pressed():
	self.disabled = true 
	
	if has_node("SesTikla"):
		$SesTikla.play()
	
	scale = Vector2(0.9, 0.9)
	await get_tree().create_timer(0.1).timeout
	
	if has_node("/root/OyunVerisi"):
		OyunVerisi.hafizayi_sifirla()
		
	
	if is_instance_valid(get_node_or_null("/root/GorevArayuzu")):
		get_node("/root/GorevArayuzu").visible = true
	
	if has_node("/root/SahneGecisi"):
		SahneGecisi.gecis_yap("res://okulcutscene.tscn")
	else:
		get_tree().change_scene_to_file("res://okulcutscene.tscn")

func renk_doldur(alpha_degeri: float):
	var guncel_renk = Color(1, 1, 1, alpha_degeri) 
	add_theme_color_override("font_color", guncel_renk)
	add_theme_color_override("font_hover_color", guncel_renk)
	add_theme_color_override("font_focus_color", guncel_renk)
	add_theme_color_override("font_pressed_color", guncel_renk)
