extends Node3D 

@export var min_bekleme: float = 2.0
@export var max_bekleme: float = 5.0
@export var ekranda_kalma: float = 0.3

func _ready():
	visible = false 
	randomize() 
	korku_dongusunu_baslat()

func korku_dongusunu_baslat():
	var bekleme_suresi = randf_range(min_bekleme, max_bekleme)
	await get_tree().create_timer(bekleme_suresi).timeout
	
	visible = true
	
	await get_tree().create_timer(ekranda_kalma).timeout
	
	visible = false
	korku_dongusunu_baslat()
