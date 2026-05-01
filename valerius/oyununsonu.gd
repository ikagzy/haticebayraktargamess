extends Node

var canvas: CanvasLayer
var arka_plan: ColorRect
var yazi: Label

const YAZI_FONT = "res://SpecialElite.ttf"
const MONTSERRAT = "res://Montserrat-VariableFont_wght.ttf"
const ARKAPLAN_SES = "res://oyununsonu_arasahne_2.mp3"
const CREDITS_METIN = "VALERİUS\n\n\nCoder\nKağan KABUL\nAlperen KILIÇ\n\n\nLevel Design\nAlperen KILIÇ\n\n\nSes Tasarımı\nÖmer AÇIKGÖZ\n\n\nTester\nUmut Efe AGAR\nAlperen KILIÇ\n\n\n\nBu oyun Gebze Belediyesi'nin düzenlediği\nDijital Kaşifler adlı yarışma için yapılmıştır."

const SAHNELER = [
	{"metin": "İhanetin Bedelini Çok Ağır Ödeyen Birisi\n\nCONNOR", "bekleme": 4.0, "boyut": 52, "renk": Color(0.85, 0.75, 0.45)},
	{"metin": "Yüzyıllar önce, büyücülerin kendisine ihanet ettiği gece\nbir lanete mahkûm edildi.", "bekleme": 4.5, "boyut": 34, "renk": Color(0.9, 0.9, 0.9)},
	{"metin": "Bedeni yok oldu.\nAma ruhu...\nruhu bu koridorlarda kaldı.", "bekleme": 4.5, "boyut": 34, "renk": Color(0.9, 0.9, 0.9)},
	{"metin": "Yüzyıllarca yardım istedi.\nHiç kimse duymadı.\n\nTa ki sen gelene kadar.", "bekleme": 5.0, "boyut": 34, "renk": Color(0.9, 0.9, 0.9)},
	{"metin": "Şifreyi girdiğin an lanet serbest kaldı.\nConnor özgürdü artık.\n\nAma lanet kaybolmaz.", "bekleme": 5.0, "boyut": 32, "renk": Color(0.85, 0.85, 0.85)},
	{"metin": "...", "bekleme": 2.0, "boyut": 48, "renk": Color(0.6, 0.6, 0.6)},
	{"metin": "Marcus sabah uyandığında her şey normaldi.\n\nBir rüyaymış gibi.", "bekleme": 4.5, "boyut": 34, "renk": Color(0.9, 0.9, 0.9)},
	{"metin": "Komodinin üzerinde bir şey parlıyordu.", "bekleme": 3.5, "boyut": 36, "renk": Color(0.9, 0.9, 0.9)},
	{"metin": "Yüzük.", "bekleme": 3.0, "boyut": 64, "renk": Color(0.9, 0.75, 0.2)},
	{"metin": "Lanet sadece elden ele değişir.\n\nAsla kaybolmaz.", "bekleme": 6.0, "boyut": 42, "renk": Color(0.7, 0.0, 0.0)},
]

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_arayuz_kur()
	_arkaplan_sesi_baslat()
	await get_tree().create_timer(0.5).timeout
	await _sahneleri_oynat()
	await get_tree().create_timer(1.0).timeout
	await _credits_oynat()
	await get_tree().create_timer(1.5).timeout
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _arayuz_kur():
	canvas = CanvasLayer.new()
	canvas.layer = 100
	add_child(canvas)
	arka_plan = ColorRect.new()
	arka_plan.set_anchors_preset(Control.PRESET_FULL_RECT)
	arka_plan.color = Color(0, 0, 0, 1)
	arka_plan.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(arka_plan)
	yazi = Label.new()
	yazi.set_anchors_preset(Control.PRESET_FULL_RECT)
	yazi.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	yazi.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	yazi.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	yazi.mouse_filter = Control.MOUSE_FILTER_IGNORE
	yazi.modulate.a = 0.0
	var font_res = load(YAZI_FONT)
	var ayar = LabelSettings.new()
	ayar.font_size = 36
	ayar.outline_size = 5
	ayar.outline_color = Color(0, 0, 0, 1)
	ayar.font_color = Color(1, 1, 1, 1)
	if font_res:
		ayar.font = font_res
	yazi.label_settings = ayar
	canvas.add_child(yazi)

func _arkaplan_sesi_baslat():
	var ses_res = load(ARKAPLAN_SES)
	if not ses_res:
		return
	var oynatici = AudioStreamPlayer.new()
	oynatici.stream = ses_res
	oynatici.volume_db = -8.0
	add_child(oynatici)
	oynatici.play()

func _sahneleri_oynat():
	for sahne in SAHNELER:
		yazi.text = sahne["metin"]
		yazi.label_settings.font_size = sahne["boyut"]
		yazi.label_settings.font_color = sahne["renk"]
		yazi.modulate.a = 0.0
		var t_in = create_tween()
		t_in.tween_property(yazi, "modulate:a", 1.0, 1.8).set_trans(Tween.TRANS_SINE)
		await t_in.finished
		await get_tree().create_timer(sahne["bekleme"]).timeout
		var t_out = create_tween()
		t_out.tween_property(yazi, "modulate:a", 0.0, 1.2).set_trans(Tween.TRANS_SINE)
		await t_out.finished
		await get_tree().create_timer(0.4).timeout

func _credits_oynat():
	var ekran_w = get_viewport().size.x
	var ekran_h = get_viewport().size.y

	var credits_label = Label.new()
	credits_label.text = CREDITS_METIN
	credits_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credits_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	credits_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	credits_label.custom_minimum_size = Vector2(ekran_w, 0)
	credits_label.position = Vector2(0, ekran_h)

	var mont = load(MONTSERRAT)
	var credits_ayar = LabelSettings.new()
	credits_ayar.font_size = 32
	credits_ayar.line_spacing = 14
	credits_ayar.outline_size = 4
	credits_ayar.outline_color = Color(0, 0, 0, 1)
	credits_ayar.font_color = Color(1, 1, 1, 1)
	if mont:
		credits_ayar.font = mont
	credits_label.label_settings = credits_ayar
	canvas.add_child(credits_label)

	await get_tree().process_frame
	await get_tree().process_frame

	var metin_h = credits_label.size.y
	var sure = (ekran_h + metin_h) / 80.0

	var t = create_tween()
	t.tween_property(credits_label, "position:y", -metin_h - 50, sure).set_trans(Tween.TRANS_LINEAR)
	await t.finished
	credits_label.queue_free()
