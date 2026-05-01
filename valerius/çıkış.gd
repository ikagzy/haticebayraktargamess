extends Button

func _ready():
	# Pivot noktasını merkeze alıyoruz ki merkezden küçülsün
	pivot_offset = size / 2
	
	# Sinyalleri bağlıyoruz
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Çıkış sinyalini bağla
	pressed.connect(_on_cikis_pressed) 

func _on_mouse_entered():
	# Ses çal
	if has_node("SesHover"):
		$SesHover.play()
	
	# --- HOVER ANİMASYONU (Giriş) ---
	var tween = create_tween().set_parallel(true)
	# Boyutu küçült ve rengi hafif karart
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate", Color(0.8, 0.8, 0.8), 0.1)
	
	# YAZININ İÇİNİ DOLDUR (Şeffaflığı 0'dan 1'e çek)
	tween.tween_method(renk_doldur, 0.0, 1.0, 0.2)

func _on_mouse_exited():
	# --- HOVER ANİMASYONU (Çıkış) ---
	var tween = create_tween().set_parallel(true)
	# Boyutu ve rengi eski haline getir
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.1)
	
	# YAZININ İÇİNİ BOŞALT (Şeffaflığı 1'den 0'a çek)
	tween.tween_method(renk_doldur, 1.0, 0.0, 0.2)

# Çıkış işlemi
func _on_cikis_pressed():
	if has_node("SesTikla"):
		$SesTikla.play()
	
	# Basılma efekti (Daha fazla küçülme)
	scale = Vector2(0.9, 0.9)
	
	# Sesin duyulması ve efekt için kısa bekle ve çık
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()

# --- RENK DOLDURMA FONKSİYONU ---
func renk_doldur(alpha_degeri: float):
	var guncel_renk = Color(1, 1, 1, alpha_degeri) 
	
	# Tüm buton durumları için font rengini güncelle
	add_theme_color_override("font_color", guncel_renk)
	add_theme_color_override("font_hover_color", guncel_renk)
	add_theme_color_override("font_focus_color", guncel_renk)
	add_theme_color_override("font_pressed_color", guncel_renk)
