extends CanvasLayer

@onready var sol_ust_gorev = $Control/VBoxContainer
@onready var orta_tab_paneli = $Control/GorevPaneli
@onready var icerik_yazisi = $Control/VBoxContainer/IcerikLabel

func _ready():
	if has_node("/root/globaltasks"):
		icerik_yazisi.text = GorevArayuzu.current_task_text

func _input(event):
	if OyunVerisi.arayuz_yasakli:
		if event.is_action_pressed("tab"):
			get_viewport().set_input_as_handled()
			return

func _process(_delta):
	if OyunVerisi.arayuz_yasakli or get_tree().current_scene.name == "MainMenu":
		if sol_ust_gorev: sol_ust_gorev.visible = false
		if orta_tab_paneli: orta_tab_paneli.visible = false
	else:
		if sol_ust_gorev: sol_ust_gorev.visible = true
