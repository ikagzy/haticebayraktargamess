extends SpotLight3D

@export var min_enerji: float = 0.2
@export var max_enerji: float = 2.0
@export var titreme_sikligi: float = 0.1

var sayac: float = 0.0

func _process(delta: float) -> void:
	sayac += delta
	
	if sayac >= titreme_sikligi:
		sayac = 0.0
		
		light_energy = randf_range(min_enerji, max_enerji)
		
		if randf() < 0.15:
			light_energy = 0.0
			
		titreme_sikligi = randf_range(0.05, 0.3)
