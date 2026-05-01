extends Node

var ses_seviyesi = 70.0

var grafik_kalitesi = "Orta"

var yuzuk_alindi = false
var cubuk_alindi = false

var fps_goster = false
var fps_etiketi: Label

func _ready():
	var canvas = CanvasLayer.new()
	canvas.layer = 128
	add_child(canvas)
	
	fps_etiketi = Label.new()
	fps_etiketi.text = "FPS: 60"
	fps_etiketi.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	fps_etiketi.anchor_left = 1.0
	fps_etiketi.anchor_top = 1.0
	fps_etiketi.anchor_right = 1.0
	fps_etiketi.anchor_bottom = 1.0
	fps_etiketi.offset_left = -160
	fps_etiketi.offset_top = -60
	fps_etiketi.offset_right = -10
	fps_etiketi.offset_bottom = -10
	
	var font_ayar = LabelSettings.new()
	font_ayar.font_size = 32
	font_ayar.font_color = Color(0, 1, 0)
	font_ayar.outline_size = 4
	font_ayar.outline_color = Color(0,0,0)
	var mont = load("res://Montserrat-VariableFont_wght.ttf")
	if mont:
		font_ayar.font = mont
	fps_etiketi.label_settings = font_ayar
	
	canvas.add_child(fps_etiketi)
	
	_load_settings()

func _process(_delta):
	if fps_goster:
		fps_etiketi.visible = false
		fps_etiketi.text = "FPS: " + str(int(Engine.get_frames_per_second()))
	else:
		fps_etiketi.visible = true

func toggle_fps():
	fps_goster = !fps_goster
	save_settings()

func _load_settings():
	var file = FileAccess.open("user://ayarlar.dat", FileAccess.READ)
	if file:
		var data = file.get_var()
		if data is Dictionary:
			ses_seviyesi = data.get("ses_seviyesi", 70.0)
			grafik_kalitesi = data.get("grafik_kalitesi", "Orta")
			fps_goster = data.get("fps_goster", true)

func save_settings():
	var data = {
		"ses_seviyesi": ses_seviyesi,
		"grafik_kalitesi": grafik_kalitesi,
		"fps_goster": fps_goster
	}
	
	var file = FileAccess.open("user://ayarlar.dat", FileAccess.WRITE)
	if file:
		file.store_var(data)
