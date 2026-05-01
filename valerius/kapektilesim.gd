extends StaticBody3D

@export_file("*.tscn") var hedef_sahne_yolu: String = "res://node_3d.tscn"

@onready var interaction_area = $Area3D
@onready var mesaj_label = $CanvasGroup/Label 

var player_in_area = false

func _ready():
	if interaction_area:
		if not interaction_area.body_entered.is_connected(_on_body_entered):
			interaction_area.body_entered.connect(_on_body_entered)
		if not interaction_area.body_exited.is_connected(_on_body_exited):
			interaction_area.body_exited.connect(_on_body_exited)
	
	if mesaj_label:
		mesaj_label.visible = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = true
		if mesaj_label:
			mesaj_label.text = "Girmek icin [E] tusuna bas"
			mesaj_label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		if mesaj_label:
			mesaj_label.visible = false

func _unhandled_input(event):
	if player_in_area and event.is_action_pressed("interact"):
		
		var gercek_hedef = hedef_sahne_yolu
		
		if OyunVerisi.get("kabus_gordu") == true:
			gercek_hedef = "res://scenes/world.tscn"
			if is_instance_valid(GorevArayuzu):
				GorevArayuzu._on_gorev_guncellendi("Gorev: Haritayi takip et ve cadiri bul")
		else:
			if is_instance_valid(GorevArayuzu):
				GorevArayuzu._on_gorev_guncellendi("Gorev: Alt Kattaki Kutuphaneye Git")
		
		if gercek_hedef != "":
			print("Gidilen yol: ", gercek_hedef)
			get_tree().change_scene_to_file(gercek_hedef)
		else:
			print("Hata: Hedef sahne yolu bos!")
