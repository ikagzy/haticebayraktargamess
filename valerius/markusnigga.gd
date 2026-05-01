extends CharacterBody3D

# ==================== HAREKET AYARLARI ====================
const WALK_SPEED = 5.0
var SPEED = WALK_SPEED 

# ==================== KAMERA AYARLARI ====================
@export var BOB_HEIGHT: float = 1.8 
const MARKUS_FREQ = 2.0
const MARKUS_AMP = 0.08
var t_markus = 0.0

# ==================== FENER VE ETKİLEŞİM AYARLARI ====================
@export var flashlight_rotation_smoothness : float = 15.0 
@export var flashlight_position_smoothness : float = 15.0 
@export var shake_intensity : float = 0.015
@export var shake_speed : float = 3.0       

@onready var head = $head
@onready var camera = $head/Camera3D
@export var SENSITIVITY: float = 0.002

@onready var isik = $head/Camera3D/SpotLight3D
@onready var raycast = $head/Camera3D/RayCast3D
@onready var etkilesim_yazisi = $CanvasLayer/Label

var isik_acik_mi = false
var fenere_sahip_mi = false 

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if not head: head = find_child("head") or find_child("Head")
	if not camera and head: camera = head.find_child("Camera3D")
	if isik: isik.set_as_top_level(true)
		
	if is_instance_valid(GorevArayuzu):
		GorevArayuzu.show()
		GorevArayuzu.set_process_input(true)
		GorevArayuzu.set_process(true)
		
	if is_instance_valid(OyunVerisi):
		OyunVerisi.arayuz_yasakli = false
		fenere_sahip_mi = OyunVerisi.fenere_sahip_mi
		isik_acik_mi = OyunVerisi.isik_acik_mi
	else:
		fenere_sahip_mi = isik != null
		isik_acik_mi = false
		
	if isik: isik.visible = isik_acik_mi 
	
	# TextureRect içine koyduğun Label'ı bul
	if not is_instance_valid(etkilesim_yazisi):
		etkilesim_yazisi = get_node_or_null("CanvasLayer/TextureRect/Label")
		if not is_instance_valid(etkilesim_yazisi): # Belki başka CanvasGroup vb içindedir
			etkilesim_yazisi = find_child("Label", true, false)
	
	if is_instance_valid(etkilesim_yazisi):
		var etk_lset = LabelSettings.new()
		etk_lset.font_size = 22
		etk_lset.outline_size = 3
		etk_lset.outline_color = Color(0, 0, 0, 1)
		var mont = load("res://Montserrat-VariableFont_wght.ttf")
		if mont:
			etk_lset.font = mont
		etkilesim_yazisi.label_settings = etk_lset
		# Set alignment safely if not a generic node wrapper
		etkilesim_yazisi.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		etkilesim_yazisi.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		etkilesim_yazisi.hide()

func _process(delta: float) -> void:
	update_flashlight(delta)
	
	if is_instance_valid(etkilesim_yazisi):
		etkilesim_yazisi.visible = false
		
	var oncelikli_yazi_aktif = false
	
	# ====================================================================
	# 1. GPS İLE MESAFE ÖLÇÜMÜ (Yurt Kapısı Tespiti)
	# ====================================================================
	var yurt_kapilari = get_tree().get_nodes_in_group("YurtKapisi")
	if yurt_kapilari.size() > 0:
		var kapi = yurt_kapilari[0]
		if global_position.distance_to(kapi.global_position) < 3.0:
			oncelikli_yazi_aktif = true
			
			var izin_var_mi = false
			if is_instance_valid(OyunVerisi):
				izin_var_mi = OyunVerisi.get("odaya_giris_izni")
			
			if not izin_var_mi:
				if is_instance_valid(etkilesim_yazisi):
					etkilesim_yazisi.text = "Kapı Kilitli... (Önce kütüphaneye git)"
					etkilesim_yazisi.visible = true
			else:
				if is_instance_valid(etkilesim_yazisi):
					etkilesim_yazisi.text = "Odaya Gir [E]"
					etkilesim_yazisi.visible = true
					
				if Input.is_action_just_pressed("interact"):
					if is_instance_valid(SahneGecisi):
						SahneGecisi.gecis_yap("res://oda.tscn")
					else:
						get_tree().change_scene_to_file("res://oda.tscn")

	# ====================================================================
	# 2. RAYCAST ETKİLEŞİMİ (Diğer Nesneler)
	# ====================================================================
	if not oncelikli_yazi_aktif and is_instance_valid(raycast) and raycast.is_colliding():
		var bakilan_obje = raycast.get_collider()
		
		if is_instance_valid(bakilan_obje) and bakilan_obje.is_in_group("Fener") and not fenere_sahip_mi:
			if is_instance_valid(etkilesim_yazisi):
				etkilesim_yazisi.text = "El Fenerini Almak İçin [E]"
				etkilesim_yazisi.visible = true
			if Input.is_action_just_pressed("interact"):
				feneri_yerden_al(bakilan_obje)
				
		elif is_instance_valid(bakilan_obje) and bakilan_obje.is_in_group("Kapi"):
			if is_instance_valid(etkilesim_yazisi):
				etkilesim_yazisi.text = "Kapıyı Aç/Kapat [E]"
				etkilesim_yazisi.visible = true
			if Input.is_action_just_pressed("interact"):
				kapiyla_etkilesime_gir(bakilan_obje)

		elif is_instance_valid(bakilan_obje) and bakilan_obje.is_in_group("Girilmez"):
			# 2. BİRİNCİ BUTONUN GÖREVLERİNİ VE ALTYAZISINI VER
			if is_instance_valid(get_node_or_null("/root/GorevArayuzu")):
				get_node("/root/GorevArayuzu").visible = true
				get_node("/root/GorevArayuzu")._on_gorev_guncellendi("Görev: Kütüphaneyi araştır")
				
				if get_node("/root/GorevArayuzu").has_method("altyazi_goster"):
					# Yazıyı 4 saniye ekranda tutuyoruz ki adam olayı anlasın
					get_node("/root/GorevArayuzu").altyazi_goster("Kütüphaneye gireceğim. En fazla ne olabilir ki?", 4.0)

				# YENİ EKLENEN: KÜTÜPHANEYE GİRİNCE EĞİLME BİLGİSİ
				if get_node("/root/GorevArayuzu").has_method("ekrana_bilgi_bas"):
					# Yazı ve görev çıktıktan 3.5 saniye sonra bilgiyi sağdan kaydırarak getir
					get_tree().create_timer(3.5).timeout.connect(func():
						get_node("/root/GorevArayuzu").ekrana_bilgi_bas("Sessiz Ol...\nEğilmek için [CTRL]")
					)

# Fener Titreme ve Kamera Efektleri
func update_flashlight(delta: float) -> void:
	if is_instance_valid(isik) and is_instance_valid(camera):
		isik.global_position = camera.global_position
		var time = Time.get_ticks_msec() * 0.001 * shake_speed
		var shake_x = sin(time * 1.1) * shake_intensity
		var shake_y = cos(time * 1.3) * shake_intensity
		var shake_z = sin(time * 0.7) * (shake_intensity * 0.5)
		
		var target_basis = camera.global_transform.basis
		target_basis = target_basis.rotated(target_basis.x, shake_x)
		target_basis = target_basis.rotated(target_basis.y, shake_y)
		target_basis = target_basis.rotated(target_basis.z, shake_z)
		
		isik.global_transform.basis = isik.global_transform.basis.slerp(target_basis, delta * flashlight_rotation_smoothness)

func feneri_yerden_al(obje):
	if is_instance_valid(obje):
		var fenerin_kendisi = obje
		if is_instance_valid(obje.get_parent()) and obje.get_parent().name not in ["Oda", "world"]:
			fenerin_kendisi = obje.get_parent()
		fenerin_kendisi.queue_free()
		fenere_sahip_mi = true
		
		if is_instance_valid(OyunVerisi):
			OyunVerisi.fenere_sahip_mi = true
			
		# YENİ EKLENEN: Feneri alınca Görevi "Koridora Çık" yap
		if is_instance_valid(GorevArayuzu):
			GorevArayuzu._on_gorev_guncellendi("Görev: Koridora Çık")

func kapiyla_etkilesime_gir(obje):
	if is_instance_valid(obje):
		if obje.has_method("etkilesime_gir"): obje.etkilesime_gir()
		elif is_instance_valid(obje.get_parent()) and obje.get_parent().has_method("etkilesime_gir"): 
			obje.get_parent().etkilesime_gir()

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * SENSITIVITY)
		if is_instance_valid(camera):
			camera.rotate_x(-event.relative.y * SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		if fenere_sahip_mi and is_instance_valid(isik):
			isik_acik_mi = !isik_acik_mi
			isik.visible = isik_acik_mi
			if is_instance_valid(OyunVerisi):
				OyunVerisi.isik_acik_mi = isik_acik_mi

func _physics_process(delta: float) -> void:
	if not is_on_floor(): velocity += get_gravity() * delta
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	update_camera_effects(delta)
	move_and_slide()

func update_camera_effects(delta: float) -> void:
	if is_on_floor() and velocity.length() > 0.1:
		t_markus += delta * velocity.length()
		var bob_pos = _headmarkus(t_markus)
		if is_instance_valid(camera):
			camera.transform.origin.y = BOB_HEIGHT + bob_pos.y
			camera.transform.origin.x = bob_pos.x
	else:
		if is_instance_valid(camera):
			camera.transform.origin.y = lerp(camera.transform.origin.y, BOB_HEIGHT, delta * 10.0)
			camera.transform.origin.x = lerp(camera.transform.origin.x, 0.0, delta * 10.0)

func _headmarkus(time) -> Vector3:
	return Vector3(cos(time * MARKUS_FREQ / 2) * MARKUS_AMP, sin(time * MARKUS_FREQ) * MARKUS_AMP, 0)
