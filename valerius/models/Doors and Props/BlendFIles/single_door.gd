extends Node3D 

@onready var anim_player = $AnimationPlayer2
var acik_mi = false

func etkilesime_gir():
	if anim_player.is_playing():
		return
		
	if acik_mi:
		anim_player.play("kapi_kapali")
		acik_mi = false
	else:
		anim_player.play("kapı_acik")
		acik_mi = true
