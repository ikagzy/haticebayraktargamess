extends OmniLight3D

var flicker_speed: float = 5.0
var flicker_strength: float = 0.5
var base_energy: float = 1.0
var time_passed: float = 0.0

func _process(delta: float) -> void:
	time_passed += delta
	var energy_variation = sin(time_passed * flicker_speed) * flicker_strength
	light_energy = base_energy + energy_variation
