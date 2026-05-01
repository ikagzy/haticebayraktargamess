extends CharacterBody3D

# ==================== HAREKET AYARLARI ====================
var WALK_SPEED = 4.0
var SPRINT_SPEED = 5.8
var SPEED = WALK_SPEED
var dev_mode_aktif = false
var dev_tween : Tween
var dev_light : OmniLight3D = null

# SES DÜĞÜMLERİ
@onready var fener_sesi = $FenerSesi
@onready var ayak_sesi = $AyakSesi
var adim_sayaci: float = 0.0 

# ==================== EĞİLME AYARLARI ====================
@export var CROUCH_SPEED = 2.5
@export var CROUCH_DEPTH = 0.8 
var is_crouching = false
var current_base_height = 0.0 

# ==================== FENER SMOOTH VE TİTREME AYARLARI ====================
@export var flashlight_rotation_smoothness : float = 15.0 
@export var flashlight_position_smoothness : float = 15.0 
@export var shake_intensity : float = 0.012 
@export var shake_speed : float = 3.0      

# ==================== STAMINA AYARLARI ====================
@export var max_stamina: float = 100.0
@export var stamina_deplete_rate: float = 15.0 # (Eskiden 40.0 idi) Saniyede 15 yorulacak, 6.5 - 7 saniye koşabilecek
@export var stamina_regen_rate: float = 18.0 # (Eskiden 25.0 idi) Dinlenince saniyede 18 enerji dolacak
@export var stamina_regen_delay: float = 1.5
@export var show_on_full_duration: float = 2.0  
var full_stamina_timer: float = 0.0
var stamina_was_full: bool = false
@export var bar_fade_speed: float = 5.0  

var current_stamina: float
var is_sprinting: bool = false
var stamina_delay_timer: float = 0.0
var target_bar_opacity: float = 0.0  
@onready var stamina_bar : TextureProgressBar = $head/TextureProgressBar  

# ==================== KAMERA AYARLARI ====================
@export var BOB_HEIGHT: float = 1.8 
var MARKUS_FREQ: float = 2.0
var MARKUS_AMP: float = 0.08
var t_markus = 0.0

const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

@onready var head = $head
@onready var camera = $head/Camera3D

@export var SENSITIVITY: float = 0.002

# ==================== FENER VE ETKİLEŞİM SİSTEMİ ====================
@onready var isik = $head/Camera3D/SpotLight3D
@onready var raycast = $head/Camera3D/RayCast3D 
@onready var etkilesim_yazisi = $CanvasLayer/Label 

var isik_acik_mi = false
var fenere_sahip_mi = false 

func _ready() -> void:
	# --- MERDİVEN YAPİŞTİRİCİSİ VE STAMINA ---
	floor_snap_length = 0.4 
	current_stamina = max_stamina
	current_base_height = BOB_HEIGHT 
	
	if stamina_bar:
		stamina_bar.modulate.a = 0.0
		stamina_bar.visible = false

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if not head: head = find_child("head") or find_child("Head")
	if not camera and head: camera = head.find_child("Camera3D")
	
	if isik:
		isik.set_as_top_level(true)

	# --- HAFIZA VE FENER KONTROLÜ ---
	fenere_sahip_mi = OyunVerisi.fenere_sahip_mi
	isik_acik_mi = OyunVerisi.isik_acik_mi
	
	if isik:
		if fenere_sahip_mi:
			isik.visible = isik_acik_mi
		else:
			isik.visible = false
			isik_acik_mi = false
			OyunVerisi.isik_acik_mi = false

	if etkilesim_yazisi:
		# OTOMATİK BOYUT VE HİZALAMA SİSTEMİ (TÜM YAZILAR İÇİN)
		etkilesim_yazisi.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		etkilesim_yazisi.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		etkilesim_yazisi.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var etk_lset = LabelSettings.new()
		etk_lset.font_size = 22
		etk_lset.outline_size = 3
		etk_lset.outline_color = Color(0, 0, 0, 1)
		var mont_font = load("res://Montserrat-VariableFont_wght.ttf")
		if mont_font:
			etk_lset.font = mont_font
		etkilesim_yazisi.label_settings = etk_lset
		etkilesim_yazisi.hide()

	# ==========================================================
	# === KÜTÜPHANE TUZAĞINDAN GELDİYSEK (1. BUTON SİSTEMİ) ===
	# ==========================================================
	if OyunVerisi.get("kutuphaneden_geldi") == true:
		
		# Hafızayı sıfırla ki adam her öldüğünde/başladığında burada doğmasın
		OyunVerisi.kutuphaneden_geldi = false 
		
		# 1. KARAKTERİ KÜTÜPHANEYE IŞINLA (-13, 0, -15)
		global_position = Vector3(-13, 0, -15)
		rotation_degrees = Vector3(0, 0, 0)
		
		# 2. BİRİNCİ BUTONUN GÖREVLERİNİ VE ALTYAZISINI VER
		if is_instance_valid(get_node_or_null("/root/GorevArayuzu")):
			get_node("/root/GorevArayuzu").visible = true
			get_node("/root/GorevArayuzu")._on_gorev_guncellendi("Görev: Kütüphaneyi araştır")
			
			if get_node("/root/GorevArayuzu").has_method("altyazi_goster"):
				# Yazıyı 4 saniye ekranda tutuyoruz ki adam olayı anlasın
				get_node("/root/GorevArayuzu").altyazi_goster("Kütüphaneye gireceğim. En fazla ne olabilir ki?", 4.0)

			# === YENİ EKLENEN: EĞİLME BİLGİ KUTUSU YOL HARİTASI ===
			if get_node("/root/GorevArayuzu").has_method("ekrana_bilgi_bas"):
				# Altyazıdan 3.5 saniye sonra sessizce sağdan bilgi kutusu kaysın
				get_tree().create_timer(3.5).timeout.connect(func():
					get_node("/root/GorevArayuzu").ekrana_bilgi_bas("Sessiz Ol...\nEğilmek için [CTRL]")
				)

func _process(delta: float) -> void:
	update_flashlight(delta)
	
	if etkilesim_yazisi:
		etkilesim_yazisi.visible = false
	
	if raycast and raycast.is_colliding():
		var bakilan_obje = raycast.get_collider()
		
		# Akıllı Fener Bulucu: Baktığı objeden en üst klasöre kadar 'fener' kelimesini arar.
		var fener_bulundu = false
		var arama_objesi = bakilan_obje
		while arama_objesi != null and arama_objesi != get_tree().root:
			if arama_objesi.is_in_group("Fener") or "fener" in arama_objesi.name.to_lower():
				fener_bulundu = true
				break
			arama_objesi = arama_objesi.get_parent()
			
		if fener_bulundu and not fenere_sahip_mi:
			if etkilesim_yazisi:
				etkilesim_yazisi.text = "Feneri Al [E]"
				etkilesim_yazisi.visible = true
			if Input.is_action_just_pressed("interact"):
				feneri_yerden_al(bakilan_obje)
				
		elif bakilan_obje and bakilan_obje.is_in_group("Kapi"):
			if etkilesim_yazisi:
				etkilesim_yazisi.text = "Kapıyı Aç/Kapat [E]"
				etkilesim_yazisi.visible = true
			if Input.is_action_just_pressed("interact"):
				kapiyla_etkilesime_gir(bakilan_obje)
				
		elif bakilan_obje and bakilan_obje.is_in_group("Girilmez"):
			if etkilesim_yazisi:
				etkilesim_yazisi.text = "Kapı kilitli [E]"
				etkilesim_yazisi.visible = true
			if Input.is_action_just_pressed("interact"):
				if is_instance_valid(get_node_or_null("/root/GorevArayuzu")) and GorevArayuzu.has_method("altyazi_goster"):
					GorevArayuzu.altyazi_goster("Kapı kilitli... Açamıyorum.", 2.5)
						
		elif bakilan_obje and (bakilan_obje.is_in_group("SihirliKitap") or (bakilan_obje.get_parent() and bakilan_obje.get_parent().is_in_group("SihirliKitap"))):
			if etkilesim_yazisi:
				etkilesim_yazisi.text = "Kitabı İncele [E]"
				etkilesim_yazisi.visible = true
			if Input.is_action_just_pressed("interact"):
				# Eğer obje özel olarak kitabı kriz şeklinde açacak fonksiyona sahipse karakterin kendisini gönderelim
				if bakilan_obje.has_method("kitap_etkilesimi"):
					bakilan_obje.kitap_etkilesimi(self)
				elif bakilan_obje.get_parent().has_method("kitap_etkilesimi"):
					bakilan_obje.get_parent().kitap_etkilesimi(self)
				elif bakilan_obje.has_method("etkilesime_gir"):
					bakilan_obje.etkilesime_gir()
				elif bakilan_obje.get_parent().has_method("etkilesime_gir"):
					bakilan_obje.get_parent().etkilesime_gir()
				
		elif bakilan_obje and (bakilan_obje.is_in_group("Anahtar") or (bakilan_obje.get_parent() and bakilan_obje.get_parent().is_in_group("Anahtar"))):
			if etkilesim_yazisi:
				etkilesim_yazisi.text = "Anahtarı Al [E]"
				etkilesim_yazisi.visible = true
			if Input.is_action_just_pressed("interact"):
				anahtari_al(bakilan_obje)

# ==================== FENER SMOOTH TAKİP VE TİTREME ====================
func update_flashlight(delta: float) -> void:
	if isik and camera:
		isik.global_position = camera.global_position
		
		var time = Time.get_ticks_msec() * 0.001 * shake_speed
		var shake_x = sin(time * 1.1) * shake_intensity
		var shake_y = cos(time * 1.3) * shake_intensity
		var shake_z = sin(time * 0.7) * (shake_intensity * 0.5)
		
		var target_basis = camera.global_transform.basis
		target_basis = target_basis.rotated(target_basis.x, shake_x)
		target_basis = target_basis.rotated(target_basis.y, shake_y)
		target_basis = target_basis.rotated(target_basis.z, shake_z)
		
		isik.global_transform.basis = isik.global_transform.basis.slerp(
			target_basis, 
			delta * flashlight_rotation_smoothness
		)

# ==================== DİĞER FONKSİYONLAR ====================
func feneri_yerden_al(obje):
	var fenerin_kendisi = obje
	if obje.get_parent() and obje.get_parent().name != "Oda" and obje.get_parent().name != "world":
		fenerin_kendisi = obje.get_parent()
	fenerin_kendisi.queue_free()
	
	fenere_sahip_mi = true
	OyunVerisi.fenere_sahip_mi = true
	
	if is_instance_valid(get_node_or_null("/root/GorevArayuzu")):
		GorevArayuzu._on_gorev_guncellendi("Odadan çık")

func kapiyla_etkilesime_gir(obje):
	if obje.has_method("etkilesime_gir"):
		obje.etkilesime_gir()
	elif obje.get_parent().has_method("etkilesime_gir"):
		obje.get_parent().etkilesime_gir()

func anahtari_al(obje):
	# Kitap okunmadan anahtar alınamaz!
	if not OyunVerisi.get("kapi_acildi"):
		if is_instance_valid(get_node_or_null("/root/GorevArayuzu")):
			GorevArayuzu.altyazi_goster("Önce kütüphaneyi araştırmalıyım...", 2.5)
		return

	# Hem objenin kendisi hem de parentı Anahtar grubunda olabilir
	var hedef = obje
	if obje.get_parent() and (obje.get_parent().is_in_group("Anahtar") or "anahtar" in obje.get_parent().name.to_lower()):
		hedef = obje.get_parent()
	hedef.queue_free()
	
	if is_instance_valid(OyunVerisi):
		OyunVerisi.anahtar_alindi = true
	
	if is_instance_valid(get_node_or_null("/root/GorevArayuzu")):
		GorevArayuzu._on_gorev_guncellendi("Görev: Anahtarla çıkışı bul")
		GorevArayuzu.altyazi_goster("Anahtarı buldum! Şimdi çıkabilir miyim...", 3.0)

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED)

	if event is InputEventKey and event.pressed and event.keycode == KEY_F and fenere_sahip_mi:
		if isik:
			isik_acik_mi = !isik_acik_mi
			isik.visible = isik_acik_mi
			OyunVerisi.isik_acik_mi = isik_acik_mi
			if fener_sesi:
				fener_sesi.play() 

func show_dev_text(mesaj: String, renk: Color):
	var canvas = get_node_or_null("DevCanvas")
	if not canvas:
		canvas = CanvasLayer.new()
		canvas.name = "DevCanvas"
		canvas.layer = 125
		add_child(canvas)
		
		var yeni_lbl = Label.new()
		yeni_lbl.name = "DevLabel"
		yeni_lbl.set_anchors_preset(Control.PRESET_TOP_WIDE)
		yeni_lbl.position.y = 40
		yeni_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		var lset = LabelSettings.new()
		lset.font_size = 24
		lset.outline_size = 4
		lset.outline_color = Color(0,0,0)
		var mont_font2 = load("res://Montserrat-VariableFont_wght.ttf")
		if mont_font2:
			lset.font = mont_font2
		yeni_lbl.label_settings = lset
		
		canvas.add_child(yeni_lbl)
	
	var lbl = canvas.get_node("DevLabel")
	lbl.text = mesaj
	lbl.label_settings.font_color = renk
	lbl.modulate.a = 1.0
	
	if dev_tween and dev_tween.is_valid():
		dev_tween.kill()
		
	dev_tween = create_tween()
	dev_tween.tween_interval(2.0)
	dev_tween.tween_property(lbl, "modulate:a", 0.0, 1.0)

func handle_crouch() -> void:
	if Input.is_action_pressed("crouch"):
		is_crouching = true
		SPEED = CROUCH_SPEED
		current_base_height = BOB_HEIGHT - CROUCH_DEPTH
	else:
		is_crouching = false
		current_base_height = BOB_HEIGHT

func _physics_process(delta: float) -> void:
	# ==================== DEVELOPER MODE TOGGLE ====================
	if Input.is_action_just_pressed("developer_mode"):
		dev_mode_aktif = !dev_mode_aktif
		if dev_mode_aktif:
			WALK_SPEED = 15.0
			SPRINT_SPEED = 25.0
			
			# Stamina Barını Kaldır / Sınırsız Yap
			stamina_deplete_rate = 0.0
			current_stamina = max_stamina
			if stamina_bar:
				stamina_bar.visible = false
				stamina_bar.modulate.a = 0.0
			target_bar_opacity = 0.0
				
			# Etrafı Aydınlat (OmniLight)
			if not dev_light:
				dev_light = OmniLight3D.new()
				dev_light.omni_range = 60.0
				dev_light.light_energy = 8.0
				dev_light.light_color = Color(1.0, 1.0, 1.0)
				dev_light.shadow_enabled = false
				dev_light.position = Vector3(0, 2, 0)
				add_child(dev_light)
			dev_light.visible = true
			
			show_dev_text("Developer Mode: AKTİF (Hız, Sınırsız Stamina, Işık)", Color(0.2, 1.0, 0.2))
		else:
			WALK_SPEED = 4.0
			SPRINT_SPEED = 5.8
			
			# Staminayı eski haline getir
			stamina_deplete_rate = 15.0
			
			# Işığı Kapat
			if dev_light:
				dev_light.visible = false
				
			show_dev_text("Developer Mode: KAPALI", Color(1.0, 0.2, 0.2))

	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Geliştirici modunda SPACE (Boşluk) tuşuna basınca zıplama
	if dev_mode_aktif and Input.is_physical_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = 8.0
		
	handle_crouch()
	handle_sprint_and_stamina(delta)
	
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if is_on_floor() and velocity.length() > 0.5:
		adim_sayaci += delta
		var adim_araligi = 0.75 
		if is_sprinting: adim_araligi = 0.35 
		if is_crouching: adim_araligi = 1.1  
		
		if adim_sayaci >= adim_araligi:
			if ayak_sesi:
				ayak_sesi.pitch_scale = randf_range(0.85, 1.15) 
				ayak_sesi.play()
			adim_sayaci = 0.0
	else:
		adim_sayaci = 0.0 
		if ayak_sesi and ayak_sesi.playing:
			ayak_sesi.stop() 
		
	update_camera_effects(delta)
	update_bar_opacity(delta)
	move_and_slide()

var is_exhausted: bool = false
var stamina_uyari_gosterildi: bool = false
var nefes_tukenme_oynatici: AudioStreamPlayer
var yorgunluk_ekrani: ColorRect

func handle_sprint_and_stamina(delta: float) -> void:
	# Eğer enerji barın tamamı bittiyse "Kalp Krizi / Tükenme" kilidini aç!
	if current_stamina <= 0.0 and not is_exhausted:
		is_exhausted = true
		_tukenme_baslat()
		
	# Oyuncu Shift tuşunu bırakmışsa ve dinlenmişse (%15 enerjiyi kurtarmışsa) kriz kilidi açılsın
	if is_exhausted and not Input.is_action_pressed("sprint") and current_stamina > (max_stamina * 0.15):
		is_exhausted = false
		_tukenme_bitir()
		
	# Koşabilmek için Shift, enerjinin olması VE tükenmemiş olması lazım
	var can_sprint = not is_exhausted and current_stamina > 0 and Input.is_action_pressed("sprint") and not is_crouching
	
	if can_sprint and velocity.length() > 0.1:
		is_sprinting = true
		if not is_crouching: 
			SPEED = SPRINT_SPEED
		target_bar_opacity = 1.0
		current_stamina -= stamina_deplete_rate * delta
		
		# Koşarken sürekli nefes sayacını tazeler. Yani bar anında dolmaya BAŞLAMAZ.
		stamina_delay_timer = stamina_regen_delay
	else:
		is_sprinting = false
		if not is_crouching: 
			SPEED = WALK_SPEED
		target_bar_opacity = 0.0 if current_stamina >= max_stamina else 1.0
		
		# Oyuncu koşmayı kestiyse bariyer (nefeslenme) sayacı başlar
		if stamina_delay_timer > 0.0:
			stamina_delay_timer -= delta
		else:
			# Ancak nefesi düzene girince dayanıklılığı artar!
			if current_stamina < max_stamina:
				current_stamina += stamina_regen_rate * delta

	current_stamina = clamp(current_stamina, 0, max_stamina)
	
	if stamina_bar:
		stamina_bar.value = (current_stamina / max_stamina) * 100
		update_bar_color()

func update_bar_opacity(delta: float) -> void:
	if stamina_bar:
		stamina_bar.modulate.a = lerp(stamina_bar.modulate.a, target_bar_opacity, delta * bar_fade_speed)
		stamina_bar.visible = stamina_bar.modulate.a > 0.01

func update_camera_effects(delta: float) -> void:
	var target_pos = Vector3.ZERO
	if is_on_floor() and velocity.length() > 0.1:
		t_markus += delta * velocity.length()
		var bob_pos = _headmarkus(t_markus)
		target_pos = Vector3(bob_pos.x, current_base_height + bob_pos.y, 0)
	else:
		target_pos = Vector3(0, current_base_height, 0)
	camera.transform.origin = camera.transform.origin.lerp(target_pos, delta * 10.0)
	var target_fov = BASE_FOV + FOV_CHANGE * clamp(velocity.length(), 0.5, SPRINT_SPEED)
	if is_sprinting: target_fov += 5.0
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

func _tukenme_baslat():
	if not yorgunluk_ekrani:
		var canvas = CanvasLayer.new()
		canvas.layer = 90
		add_child(canvas)
		
		yorgunluk_ekrani = ColorRect.new()
		yorgunluk_ekrani.set_anchors_preset(Control.PRESET_FULL_RECT)
		yorgunluk_ekrani.color = Color(0.2, 0.0, 0.0, 0.0) 
		yorgunluk_ekrani.mouse_filter = Control.MOUSE_FILTER_IGNORE
		canvas.add_child(yorgunluk_ekrani)
		
	var tween = create_tween()
	tween.tween_property(yorgunluk_ekrani, "color:a", 0.15, 0.5)
	
	if not nefes_tukenme_oynatici:
		nefes_tukenme_oynatici = AudioStreamPlayer.new()
		var stream = load("res://KALEESYALAR/Breathing_effect.mp3")
		if stream:
			stream.loop = true
		nefes_tukenme_oynatici.stream = stream
		nefes_tukenme_oynatici.bus = "Master"
		add_child(nefes_tukenme_oynatici)
		
	nefes_tukenme_oynatici.volume_db = -5.0
	nefes_tukenme_oynatici.play()
	
	if not stamina_uyari_gosterildi:
		stamina_uyari_gosterildi = true
		if is_instance_valid(get_node_or_null("/root/GorevArayuzu")) and GorevArayuzu.has_method("ekrana_bilgi_bas"):
			GorevArayuzu.ekrana_bilgi_bas("Nefesin tükendi...\nKoşabilmek için dinlen")

func _tukenme_bitir():
	if yorgunluk_ekrani:
		var tween = create_tween()
		tween.tween_property(yorgunluk_ekrani, "color:a", 0.0, 1.0)
		
	if nefes_tukenme_oynatici and nefes_tukenme_oynatici.playing:
		var tween = create_tween()
		tween.tween_property(nefes_tukenme_oynatici, "volume_db", -80.0, 1.0)
		tween.tween_callback(nefes_tukenme_oynatici.stop)

func _headmarkus(time) -> Vector3:
	return Vector3(cos(time * MARKUS_FREQ / 2) * MARKUS_AMP, sin(time * MARKUS_FREQ) * MARKUS_AMP, 0)

func update_bar_color() -> void:
	if stamina_bar:
		var sp = current_stamina / max_stamina
		stamina_bar.self_modulate = Color(1.0 - sp, sp, 0.2) if sp < 0.7 else Color(0, 1, 0.3)

# ==================== KALICI TRAVMA EFEKTİ ====================
func kalici_travma_baslat():
	# Zaten varsa bir daha ekleme
	if has_node("KaliciTravmaCanvas"):
		return
		
	# Y�r�y�� h�z�n� d���r ve kafa sallanmas�n� (ba� d�nmesi) artt�r
	WALK_SPEED = 1.8         # Sendeleyerek y�r�me
	SPRINT_SPEED = 2.5       # Ko�maya �al��sa da a��r
	MARKUS_AMP = 0.18        # Kamera/G�r�� �ok dalgalanacak (normali 0.08)
	MARKUS_FREQ = 2.5        # Nefes nefese titreme (normali 2.0)
	SPEED = WALK_SPEED
		
	var canvas = CanvasLayer.new()
	canvas.name = "KaliciTravmaCanvas"
	canvas.layer = 95 # Arayüzün altında ama oyunun üstünde
	add_child(canvas)
	
	var cr = ColorRect.new()
	cr.set_anchors_preset(Control.PRESET_FULL_RECT)
	cr.color = Color(0.3, 0.0, 0.0, 0.0) # Hafif kırmızı
	cr.mouse_filter = Control.MOUSE_FILTER_IGNORE # Fareyi engellemesini iptal et
	canvas.add_child(cr)
	
	# Sonsuz kalp atışı döngüsü
	var tween = create_tween().set_loops()
	tween.tween_property(cr, "color:a", 0.2, 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(cr, "color:a", 0.05, 0.8).set_trans(Tween.TRANS_SINE)
