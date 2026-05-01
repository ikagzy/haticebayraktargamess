extends Node

@onready var anim_player = $AnimationPlayer

func _ready():
	if anim_player and anim_player.has_animation("Kale_animasyon"):
		anim_player.play("Kale_animasyon")
		await anim_player.animation_finished
	else:
		push_warning("HATA: 'kale_arasahne' animasyonu veya AnimationPlayer bulunamadı! İsimleri kontrol et.")
		await get_tree().create_timer(2.0).timeout
	
	
	get_tree().change_scene_to_file("res://kale.tscn")
