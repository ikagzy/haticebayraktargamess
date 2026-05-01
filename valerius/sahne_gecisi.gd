extends CanvasLayer

@onready var siyah_ekran = $ColorRect

func _ready():
	siyah_ekran.show()
	siyah_ekran.modulate.a = 0.0 

func gecis_yap(yeni_sahne_yolu: String):
	var tween_karar = get_tree().create_tween()
	tween_karar.tween_property(siyah_ekran, "modulate:a", 1.0, 1.5)
	
	await tween_karar.finished
	
	await get_tree().create_timer(0.5).timeout
	
	get_tree().change_scene_to_file(yeni_sahne_yolu)
	
	var tween_aydinlan = get_tree().create_tween()
	tween_aydinlan.tween_property(siyah_ekran, "modulate:a", 0.0, 1.5)
