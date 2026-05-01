extends OmniLight3D

@export var min_enerji = 0.0
@export var maks_enerji = 2.0
@export var titreme_hizi = 0.05

var zaman_sayaci = 0.0

func _process(delta):
	zaman_sayaci += delta
	
	if zaman_sayaci > titreme_hizi:
		light_energy = randf_range(min_enerji, maks_enerji)
		
		zaman_sayaci = 0.0
		
		titreme_hizi = randf_range(0.02, 0.15)
