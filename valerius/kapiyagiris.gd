extends Area3D

var hedef_sahne_yolu: String = "res://scenes/world.tscn"
@onready var mesaj_label = get_node_or_null("../CanvasGroup/Label") 

var player_in_area = false

func _ready():
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)
	
	if is_instance_valid(mesaj_label):
		mesaj_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		mesaj_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		mesaj_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var kapi_lset = LabelSettings.new()
		kapi_lset.font_size = 22
		kapi_lset.outline_size = 3
		kapi_lset.outline_color = Color(0, 0, 0, 1)
		var mont = load("res://Montserrat-VariableFont_wght.ttf")
		if mont:
			kapi_lset.font = mont
		mesaj_label.label_settings = kapi_lset
		mesaj_label.visible = false

func _on_body_entered(body):
	var izin_var_mi = OyunVerisi.get("odaya_giris_izni")
	if not izin_var_mi:
		return 
		
	if body.name == "Player" or body.is_in_group("player") or body is CharacterBody3D:
		player_in_area = true
		if is_instance_valid(mesaj_label):
			mesaj_label.text = "Girmek için [E] tuşuna bas"
			mesaj_label.show()

func _on_body_exited(body):
	if body.name == "Player" or body.is_in_group("player") or body is CharacterBody3D:
		player_in_area = false
		if is_instance_valid(mesaj_label):
			mesaj_label.hide()

func _process(_delta):
	var izin_var_mi = OyunVerisi.get("odaya_giris_izni")
	if not izin_var_mi:
		return
		
	if player_in_area and Input.is_action_just_pressed("interact"):
		if hedef_sahne_yolu != "":
			print("Geçiş Tetiklendi: ", hedef_sahne_yolu)
			
			if is_instance_valid(SahneGecisi):
				SahneGecisi.gecis_yap(hedef_sahne_yolu)
			else:
				get_tree().change_scene_to_file(hedef_sahne_yolu)
