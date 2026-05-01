extends Area3D

# Çadır ve Sandık Etkileşimi
# Marcus burada Yüzük (Ring) ve Çubuk (Wand) bulur.

func _on_body_entered(body: Node3D):
	if body.is_in_group("Player"):
		if is_instance_valid(GorevArayuzu):
			GorevArayuzu.altyazi_goster("Bu çadırda bir şeyler olmalı...", 3.0)

func sandigi_ac():
	var canvas = CanvasLayer.new()
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.5)
	
	var label = Label.new()
	label.text = "Sandıkta parıldayan bir yüzük var. Garip bir enerji yayıyor..."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	label.position.y = 200
	var ayarlar = LabelSettings.new()
	ayarlar.font_size = 32
	var mont = load("res://Montserrat-VariableFont_wght.ttf")
	if mont:
		ayarlar.font = mont
	label.label_settings = ayarlar
	
	var btn_al = Button.new()
	btn_al.text = "Yüzüğü Al"
	btn_al.position = Vector2(400, 400)
	btn_al.size = Vector2(200, 50)
	btn_al.pressed.connect(func():
		OyunVerisi.yuzuk_sahip = true
		sandik_secimi_yapildi(canvas)
	)
	
	var btn_alma = Button.new()
	btn_alma.text = "Sandıktan Uzaklaş"
	btn_alma.position = Vector2(700, 400)
	btn_alma.size = Vector2(250, 50)
	btn_alma.pressed.connect(func():
		OyunVerisi.yuzuk_sahip = false
		sandik_secimi_yapildi(canvas)
	)
	
	bg.add_child(label)
	bg.add_child(btn_al)
	bg.add_child(btn_alma)
	canvas.add_child(bg)
	add_child(canvas)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true

func sandik_secimi_yapildi(canvas: CanvasLayer):
	canvas.queue_free()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	GorevArayuzu._on_gorev_guncellendi("Görev: Terk Edilmiş Kaleye Git")
	
	if OyunVerisi.yuzuk_sahip:
		GorevArayuzu.altyazi_goster("Marcus: 'Bu yüzük... İçindeki enerji beni kendine çekiyor sanki.'", 3.0)
	else:
		GorevArayuzu.altyazi_goster("Marcus: 'Bu garip yüzüğe dokunmasam daha iyi...'", 3.0)
