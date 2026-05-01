extends Area3D

var oyuncu_kapida = false

@onready var etkilesim_yazisi = get_node_or_null("CanvasLayer/Label")

func _ready():
	if is_instance_valid(etkilesim_yazisi):
		etkilesim_yazisi.hide()

func _on_body_entered(body):
	pass

func _on_body_exited(body):
	pass

func _process(_delta):
	pass
