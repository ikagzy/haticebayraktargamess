extends CanvasLayer

# Butonların içinde olduğu klasörü buraya tanımlıyoruz
@onready var buton_kutusu = $ButonKutusu 
var asil_pozisyon_x: float = 0.0

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS 
	
	# Oyun başlarken butonların ekrandaki asıl (orijinal) X pozisyonunu hafızaya alıyoruz
	if buton_kutusu:
		asil_pozisyon_x = buton_kutusu.position.x

func _input(event):
	if event.is_action_pressed("pause"):
		var current_scene = get_tree().current_scene
		if current_scene and (current_scene.scene_file_path == "res://main_menu.tscn" or current_scene.name == "main_menu"):
			return
		
		toggle_pause()
		# ÖNEMLİ: ESC basımını burada tüketiriz, böylece Karakter scripti vs. tetiklenmez
		get_viewport().set_input_as_handled()

func toggle_pause():
	var yeni_durum = !get_tree().paused
	get_tree().paused = yeni_durum
	
	if yeni_durum:
		# ================= OYUN DURDURULDU (MENÜ AÇILIYOR) =================
		visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		# 1. Görev Yazısını Gizle
		if is_instance_valid(GorevArayuzu):
			GorevArayuzu.visible = false
			
		# 2. Butonları Kaydırarak Getir (Tween Animasyonu)
		if buton_kutusu:
			# Butonları önce ekranın 500 piksel soluna (görünmez alana) fırlatıyoruz
			buton_kutusu.position.x = asil_pozisyon_x - 500 
			
			# Animasyon motorunu (Tween) oluşturuyoruz
			var tween = create_tween()
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) # Zaman donukken animasyon çalışsın
			
			# ButonKutusu'nun pozisyonunu 0.4 saniye içinde yaylanarak (TRANS_BACK) asıl yerine getir diyoruz
			tween.tween_property(buton_kutusu, "position:x", asil_pozisyon_x, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			
	else:
		# ================= OYUN DEVAM EDİYOR (MENÜ KAPANIYOR) =================
		visible = false
		Input.call_deferred("set_mouse_mode", Input.MOUSE_MODE_CAPTURED)
		
		# Görev Yazısını Geri Getir
		if is_instance_valid(GorevArayuzu):
			GorevArayuzu.visible = true

func _on_geridonus_pressed():
	print("Buton ile oyuna dönülüyor...")
	toggle_pause()

func _on_cikis_pressed():
	# 1. Zamanı tekrar başlat
	get_tree().paused = false
	
	# 2. PAUSE MENÜYÜ ZORLA GİZLE (İşte asıl çözüm bu satır!)
	self.visible = false 
	
	# Ana menüye dönerken görev yazısını tekrar aktif edelim
	if is_instance_valid(GorevArayuzu):
		GorevArayuzu.visible = true
		
	# 3. Ana menüye geçiş yap
	get_tree().change_scene_to_file("res://main_menu.tscn")
	
	# Ana menüye dönerken görev yazısını tekrar aktif edelim ki bugda kalmasın
	if is_instance_valid(GorevArayuzu):
		GorevArayuzu.visible = true
		
	get_tree().change_scene_to_file("res://main_menu.tscn")
