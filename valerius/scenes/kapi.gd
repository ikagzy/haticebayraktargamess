extends StaticBody3D

@export_file("*.tscn") var hedef_sahne_yolu: String 

@onready var interaction_area = $Area3D
@onready var mesaj_label = $CanvasGroup/Label 

var player_in_area = false

func _ready():
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	if mesaj_label:
		mesaj_label.visible = false

func _on_body_entered(body):
	print("Temas eden nesne: ", body.name) 
	if body.is_in_group("player"):
		player_in_area = true
		if mesaj_label:
			mesaj_label.visible = true
		print("Oyuncu algılandı!")

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		if mesaj_label:
			mesaj_label.visible = false

func _unhandled_input(event):
	if player_in_area and event.is_action_pressed("interact"):
		if hedef_sahne_yolu != "res://oda.tscn":
			get_tree().change_scene_to_file(hedef_sahne_yolu)
