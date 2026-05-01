extends ColorRect

var target_effect_amount : float = 0.0

var transition_speed : float = 5.0


func _ready() -> void:
	material.set_shader_parameter("effect_amount", 0.0)


func _process(delta: float) -> void:
	var current_amount = material.get_shader_parameter("effect_amount")
	
	var new_amount = lerp(current_amount, target_effect_amount, transition_speed * delta)
	
	material.set_shader_parameter("effect_amount", new_amount)


func activate_time_rift() -> void:
	target_effect_amount = 0.05


func deactivate_time_rift() -> void:
	target_effect_amount = 0.0
