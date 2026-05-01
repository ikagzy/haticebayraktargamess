extends OmniLight3D

@export var en_dusuk_titreme_gucu: float = 0.8
@export var en_yuksek_titreme_gucu: float = 1.1
@export var titreme_hizi_min: float = 0.05
@export var titreme_hizi_max: float = 0.15

var orijinal_enerji: float = 1.0

func _ready():
	orijinal_enerji = light_energy
	
	_mesale_titreme_dongusu()

func _mesale_titreme_dongusu():
	var rastgele_enerji = orijinal_enerji * randf_range(en_dusuk_titreme_gucu, en_yuksek_titreme_gucu)
	
	var rastgele_sure = randf_range(titreme_hizi_min, titreme_hizi_max)
	
	var tween = create_tween()
	tween.tween_property(self , "light_energy", rastgele_enerji, rastgele_sure)
	
	tween.finished.connect(_mesale_titreme_dongusu)
