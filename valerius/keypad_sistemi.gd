extends Node3D


@export var dogru_sifre: String = "251367486"
@export var basari_mesaji: String = "AÇILDI"
@export_node_path("Node3D") var tv_node_yolu: NodePath

@export var parlayan_raflar: Array[NodePath] = []

@export_multiline var final_yazisi: String = "Raflar titredi...\n\nMarcus içgüdüsel olarak elini uzattı.\n\nSabah olduğunda, herkes onu odasında uyur bulacaktı.\nAma çantasında garip bir yüzük vardı."

const MAX_HANE = 9

var _tv_node: Node3D = null
var _tv_label: Label3D = null
var _bilgi_label: Label3D = null
var _girilen_sifre: String = ""
var _yazma_modu: bool = false
var _sifre_dogru_girildi: bool = false
var _oyuncu_iceride_mi: bool = false
var _aktif_oyuncu: Node3D = null
var _raf_yakininda: bool = false

func _ready():
	if tv_node_yolu:
		_tv_node = get_node_or_null(tv_node_yolu)
	if not _tv_node:
		_tv_node = get_parent().get_node_or_null("TV2")

	if _tv_node:
		_tv_label = Label3D.new()
		_tv_label.pixel_size = 0.005
		_tv_label.font_size = 120
		_tv_label.outline_size = 15
		_tv_label.modulate = Color(0.0, 1.0, 0.4)
		_tv_label.position = Vector3(0, 0.0, 0.5)
		_tv_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		_tv_node.add_child(_tv_label)

	var area = Area3D.new()
	area.name = "KeypadTetikBolgesi"
	var col = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(3.5, 3.5, 3.5)
	col.shape = shape
	area.add_child(col)
	add_child(area)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	_bilgi_label = Label3D.new()
	_bilgi_label.pixel_size = 0.003
	_bilgi_label.font_size = 64
	_bilgi_label.outline_size = 8
	_bilgi_label.modulate = Color(1.0, 0.8, 0.2)
	_bilgi_label.position = Vector3(0, 0.15, 0.2)
	_bilgi_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bilgi_label.visible = false
	add_child(_bilgi_label)

	_ekrani_guncelle()
	_raflarin_parlamasini_kapat()

func _raflarin_parlamasini_kapat():
	for node_yolu in parlayan_raflar:
		var raf = get_node_or_null(node_yolu)
		if not is_instance_valid(raf):
			continue

		var mesh: MeshInstance3D = null
		if raf is MeshInstance3D:
			mesh = raf
		else:
			mesh = raf.find_child("MeshInstance3D", true, false) as MeshInstance3D

		if is_instance_valid(mesh):
			var mat = mesh.get_active_material(0)
			if mat:
				var yeni_mat = mat.duplicate() as StandardMaterial3D
				if yeni_mat:
					yeni_mat.emission_enabled = false
					mesh.set_surface_override_material(0, yeni_mat)

func _on_body_entered(body: Node3D):
	if body is CharacterBody3D or body.is_in_group("Player"):
		_oyuncu_iceride_mi = true
		_aktif_oyuncu = body
		if not _yazma_modu and not _sifre_dogru_girildi:
			_bilgi_label.visible = true
			_bilgi_label.text = "[E] Şifre Gir"

func _on_body_exited(body: Node3D):
	if body == _aktif_oyuncu:
		_oyuncu_iceride_mi = false
		_bilgi_label.visible = false
		if _yazma_modu:
			_iptal_et(body)
		_aktif_oyuncu = null

func _process(_delta):
	if _sifre_dogru_girildi:
		return

	if not _yazma_modu and _oyuncu_iceride_mi:
		if Input.is_action_just_pressed("interact"):
			_yazma_modu = true
			_girilen_sifre = ""
			_ekrani_guncelle()
			_bilgi_label.text = "[ESC] İptal  |  [ENTER] Onayla"
			if is_instance_valid(_aktif_oyuncu):
				_aktif_oyuncu.set_physics_process(false)
				_aktif_oyuncu.set_process_unhandled_input(false)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if _sifre_dogru_girildi and _raf_yakininda:
		if Input.is_action_just_pressed("interact"):
			_raf_yakininda = false
			if is_instance_valid(_bilgi_label):
				_bilgi_label.visible = false
			_finali_baslat()

func _input(event):
	if not _yazma_modu or _sifre_dogru_girildi:
		return

	if event is InputEventKey and event.pressed:
		get_viewport().set_input_as_handled()

		if event.keycode == KEY_ESCAPE:
			_iptal_et(_aktif_oyuncu)

		elif (event.keycode >= KEY_0 and event.keycode <= KEY_9) or \
			 (event.keycode >= KEY_KP_0 and event.keycode <= KEY_KP_9):
			if _girilen_sifre.length() < MAX_HANE:
				var rakam = event.keycode - KEY_0 if event.keycode <= KEY_9 else event.keycode - KEY_KP_0
				_girilen_sifre += str(rakam)
				_ekrani_guncelle()

		elif event.keycode == KEY_BACKSPACE:
			if _girilen_sifre.length() > 0:
				_girilen_sifre = _girilen_sifre.substr(0, _girilen_sifre.length() - 1)
				_ekrani_guncelle()

		elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			if _girilen_sifre.length() == MAX_HANE:
				_sifre_kontrol()

func _ekrani_guncelle():
	if not is_instance_valid(_tv_label):
		return
	var gosterim = ""
	for i in range(MAX_HANE):
		gosterim += _girilen_sifre[i] if i < _girilen_sifre.length() else "_"
		if (i + 1) % 3 == 0 and i < MAX_HANE - 1:
			gosterim += "  "
	_tv_label.text = "[ ŞİFRE ]\n" + gosterim

func _iptal_et(oyuncu):
	_yazma_modu = false
	_girilen_sifre = ""
	if is_instance_valid(_tv_label):
		_tv_label.modulate = Color(0.0, 1.0, 0.4)
		_ekrani_guncelle()
	if is_instance_valid(oyuncu):
		oyuncu.set_physics_process(true)
		oyuncu.set_process_unhandled_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if is_instance_valid(_bilgi_label):
		_bilgi_label.text = "[E] Şifre Gir"

func _sifre_kontrol():
	if _girilen_sifre == dogru_sifre:
		_sifre_dogru_girildi = true
		_yazma_modu = false
		if is_instance_valid(_bilgi_label):
			_bilgi_label.visible = false
		if is_instance_valid(_tv_label):
			_tv_label.text = "[ ✓ " + basari_mesaji + " ]"
			_tv_label.modulate = Color(0.2, 1.0, 0.4)

		if is_instance_valid(_aktif_oyuncu):
			_aktif_oyuncu.set_physics_process(true)
			_aktif_oyuncu.set_process_unhandled_input(true)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://oyununsonu.tscn")
	else:
		if is_instance_valid(_tv_label):
			_tv_label.text = "[ ✗ HATA ]"
			_tv_label.modulate = Color(1.0, 0.2, 0.2)
		await get_tree().create_timer(1.2).timeout
		if not _sifre_dogru_girildi:
			_girilen_sifre = ""
			if is_instance_valid(_tv_label):
				_tv_label.modulate = Color(0.0, 1.0, 0.4)
				_ekrani_guncelle()

func _raflari_parlat():
	for node_yolu in parlayan_raflar:
		var raf = get_node_or_null(node_yolu)
		if not is_instance_valid(raf):
			continue

		var mesh: MeshInstance3D = null
		if raf is MeshInstance3D:
			mesh = raf
		else:
			mesh = raf.find_child("MeshInstance3D", true, false) as MeshInstance3D

		if is_instance_valid(mesh):
			var mat = mesh.get_active_material(0)
			if mat:
				var yeni_mat = mat.duplicate() as StandardMaterial3D
				if yeni_mat:
					yeni_mat.emission_enabled = true
					yeni_mat.emission = Color(0.8, 0.7, 0.2)
					yeni_mat.emission_energy_multiplier = 2.5
					mesh.set_surface_override_material(0, yeni_mat)

		if not raf.has_node("FinalRafArea"):
			var area2 = Area3D.new()
			area2.name = "FinalRafArea"
			var cs = CollisionShape3D.new()
			var bs = BoxShape3D.new()
			bs.size = Vector3(2.0, 2.0, 2.0)
			cs.shape = bs
			area2.add_child(cs)
			area2.body_entered.connect(_on_raf_girildi)
			area2.body_exited.connect(_on_raf_cikaldi)
			raf.add_child(area2)

func _on_raf_girildi(body):
	if not (body is CharacterBody3D or body.is_in_group("Player")):
		return
	_raf_yakininda = true
	if is_instance_valid(_bilgi_label):
		_bilgi_label.visible = true
		_bilgi_label.text = "[E] Rafa Dokun"

func _on_raf_cikaldi(body):
	if not (body is CharacterBody3D or body.is_in_group("Player")):
		return
	_raf_yakininda = false
	if is_instance_valid(_bilgi_label):
		_bilgi_label.visible = false

func _finali_baslat():
	var oyuncu = get_tree().get_first_node_in_group("Player")
	if not oyuncu:
		oyuncu = _aktif_oyuncu
	if is_instance_valid(oyuncu):
		oyuncu.set_physics_process(false)
		oyuncu.set_process_unhandled_input(false)

	OyunVerisi.gorev_yazisini_kapat()

	await _siyah_ekran_goster(final_yazisi)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _siyah_ekran_goster(metin: String):
	var canvas = CanvasLayer.new()
	canvas.layer = 120
	get_tree().root.add_child(canvas)

	var siyah = ColorRect.new()
	siyah.color = Color(0, 0, 0, 0)
	siyah.set_anchors_preset(Control.PRESET_FULL_RECT)
	siyah.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(siyah)

	var yazi = Label.new()
	yazi.text = metin
	yazi.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	yazi.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	yazi.set_anchors_preset(Control.PRESET_FULL_RECT)
	yazi.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	yazi.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var ayarlar = LabelSettings.new()
	ayarlar.font_size = 36
	ayarlar.outline_size = 4
	ayarlar.outline_color = Color(0, 0, 0, 1)
	ayarlar.font_color = Color(1, 1, 1, 1)
	var mont = load("res://Montserrat-VariableFont_wght.ttf")
	if mont:
		ayarlar.font = mont
	yazi.label_settings = ayarlar
	yazi.modulate.a = 0.0
	canvas.add_child(yazi)

	var tween = get_tree().create_tween()
	tween.tween_property(siyah, "color:a", 1.0, 2.5)
	tween.tween_interval(0.5)
	tween.tween_property(yazi, "modulate:a", 1.0, 2.0)
	tween.tween_interval(6.0)
	tween.tween_property(yazi, "modulate:a", 0.0, 1.5)
	tween.tween_interval(0.5)
	await tween.finished
