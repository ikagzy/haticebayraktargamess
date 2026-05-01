extends Node3D

# oda.gd — SADECE ANA SON yolu.
# Son #1 (Vazgeçiş) ve Son #2 (Yalan) kaldırıldı.

@onready var animasyon_oynatici = get_node_or_null("AnimationPlayer")

@export_group("Kabus & Zaman Kırılması")
@export var zaman_kirilmasi_altyazi: String = "O... O neydi? Bir şeyler ters gidiyor."
@export var maksimum_solukluk: float = 0.85 # (0.0=Tam Renkli, 1.0=Simsiyah beyaz). İstediğin gibi kısıp açabilirsin.
@export var zaman_solma_rengi: Color = Color(0.2, 0.2, 0.3) # Mavimsi gri tonu
@export var zaman_solma_saydamlik: float = 0.7 # Rengin parlaklık/kapatıcılık oranı
@export var zaman_solma_hizi: float = 3.0 # Rengin odaya yayılma hızı
@export var zaman_sarsinti_siddeti: float = 1.5 # Kameranın sallanma şiddeti
@export var zaman_sarsinti_tekrari: int = 20 # Kameranın sallanma miktarı (Kısa sürede kaç kez sallansın)


func _ready():
	if not is_instance_valid(OyunVerisi):
		return

	# Kütüphaneden döndük → NPC'leri HEMEN gizle → Yatağa git görevi
	if OyunVerisi.get("kapi_acildi") == true and not OyunVerisi.ruyada_mi:
		# 1. BAŞLANGIÇ ANİMASYONUNU İPTAL ET (Sıfırdan uyanma sekansını engeller)
		if animasyon_oynatici:
			animasyon_oynatici.stop()
			
		# Fare ve Karakter kilidini aç (Ara sahneden geliyorsa kilitli kalmış olabilir)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
		# Karakteri bul ve hareketini serbest bırak
		var oyuncu = get_node_or_null("CharacterBody3D")
		if not oyuncu:
			oyuncu = find_child("CharacterBody3D", true, false)
		if oyuncu:
			oyuncu.set_physics_process(true)
			oyuncu.set_process_unhandled_input(true)
			
			# Uyku/Kabus ara sahnesi sonrası yataktan yeni uyanmış gibi pozisyonu ve açıyı ayarla
			oyuncu.global_position = Vector3(-2.315, 0.0, -4.029)
			oyuncu.rotation_degrees = Vector3(0, -90, 0)

		# 2. GEREKSİZ NPC'LERİ TAMAMEN SİL (queue_free ile)
		var breathing = find_child("Breathing Idle", true, false)
		if is_instance_valid(breathing):
			breathing.queue_free()

		var idle_npc = find_child("Idle", true, false)
		if is_instance_valid(idle_npc):
			idle_npc.queue_free()
			
		# Özel NPCler falan varsa silinsin
		for npc in get_tree().get_nodes_in_group("NPC"):
			if is_instance_valid(npc):
				npc.queue_free()

		# 3. KABUS YENİ BİTTİYSE (ZAMAN KIRILMASI) VEYA NORMAL UYKU ÖNCESİ Mİ?
		if OyunVerisi.get("kabus_gordu") == true:
			_zaman_kirilmasi_efekti()
		else:
			# Normal yatağa gitme görevi (Kütüphaneden ilk dönüş)
			await get_tree().create_timer(0.5).timeout
			if is_instance_valid(GorevArayuzu):
				GorevArayuzu.altyazi_goster("Çok yoruldum... Biraz uyusam iyi olacak.", 4.0)
				GorevArayuzu._on_gorev_guncellendi("Görev: Yatağa Git")

# --- KABUS SONRASI: ZAMANIN KIRILMASI EFEKTİ ---
func _zaman_kirilmasi_efekti():
	# Ses efektini çal (Zamanın Durması/Kırılması Sesi)
	var ses_oynatici = AudioStreamPlayer.new()
	var ses_dosyasi = load("res://Voicy_True Time stop.mp3")
	if ses_dosyasi:
		ses_oynatici.stream = ses_dosyasi
		ses_oynatici.bus = "Master"
		add_child(ses_oynatici)
		ses_oynatici.play()
		
		# Ses bitince bellekten siliyoruz
		ses_oynatici.finished.connect(func(): ses_oynatici.queue_free())

	# Eski uyku/yatak tetiğini sil ki tekrar yatmasın
	for child in get_children():
		if child is Area3D and child.has_method("uyuma_sekansini_baslat"):
			child.queue_free()

	# 1. Altyazı
	if is_instance_valid(GorevArayuzu):
		GorevArayuzu.altyazi_goster(zaman_kirilmasi_altyazi, 4.0)
		GorevArayuzu._on_gorev_guncellendi("Görev: Dışarıyı kontrol et")
	
	# 2. Shader ve Renkleri Soldur (Zaman Parçalanması Arayüzü)
	var canvas = CanvasLayer.new()
	canvas.layer = 90 # Arayüzün altında
	add_child(canvas)
	
	var soldurucu = ColorRect.new()
	soldurucu.set_anchors_preset(Control.PRESET_FULL_RECT)
	soldurucu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(soldurucu)
	
	# Shader'ı Yükle ve Uygula
	var shader_yolu = "res://ekran_kirilmasi.gdshader"
	if ResourceLoader.exists(shader_yolu):
		var kirik_cam_materyal = ShaderMaterial.new()
		kirik_cam_materyal.shader = load(shader_yolu)
		kirik_cam_materyal.set_shader_parameter("shatter_amount", 1.0)
		kirik_cam_materyal.set_shader_parameter("aberration_amount", 5.0)
		kirik_cam_materyal.set_shader_parameter("desaturation_amount", 0.0)
		soldurucu.material = kirik_cam_materyal
		
		# Shader efektinin şiddetini zamanla azaltıp kalıcı bir kırılma bırakabiliriz
		var shader_tween = create_tween()
		shader_tween.tween_property(kirik_cam_materyal, "shader_parameter/shatter_amount", 0.05, zaman_solma_hizi * 0.5).set_trans(Tween.TRANS_ELASTIC)
		shader_tween.tween_property(kirik_cam_materyal, "shader_parameter/aberration_amount", 1.0, zaman_solma_hizi * 0.5)
		
		# Soluklaştırma: Ekranı yavaş yavaş siyah/beyaza çekiyoruz (Sıfırdan Inspector'daki Limite kadar)
		var renk_tween = create_tween()
		renk_tween.tween_property(kirik_cam_materyal, "shader_parameter/desaturation_amount", maksimum_solukluk, zaman_solma_hizi)
		
	# 3. Kamera Sarsıntısı (Zamanın Parçalanma Hissi)
	var oyuncu = get_node_or_null("CharacterBody3D")
	if not oyuncu:
		oyuncu = find_child("CharacterBody3D", true, false)
		
	if oyuncu:
		var kamera = oyuncu.get_node_or_null("head/Camera3D")
		if kamera:
			var sarsinti = create_tween().set_loops(zaman_sarsinti_tekrari)
			var base_rot = kamera.rotation.z
			sarsinti.tween_property(kamera, "rotation:z", base_rot + deg_to_rad(zaman_sarsinti_siddeti), 0.05)
			sarsinti.tween_property(kamera, "rotation:z", base_rot - deg_to_rad(zaman_sarsinti_siddeti), 0.05)
			
			get_tree().create_timer(1.0).timeout.connect(func():
				if sarsinti.is_valid():
					sarsinti.kill()
				create_tween().tween_property(kamera, "rotation:z", base_rot, 0.2)
			)
