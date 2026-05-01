@tool
class_name RadialGradientNode
extends GradientNode

const GradientNode = preload("res://addons/terrainy/nodes/gradients/gradient_node.gd")


@export_enum("Linear", "Smooth", "Spherical", "Inverse") var falloff_type: int = 1:
	set(value):
		falloff_type = value
		parameters_changed.emit()

func get_height_at(world_pos: Vector3) -> float:
	var local_pos = to_local(world_pos)
	var distance_2d = Vector2(local_pos.x, local_pos.z).length()
	
	var radius = influence_size.x
	
	if distance_2d >= radius:
		return end_height
	
	var normalized_distance = distance_2d / radius
	var t = 0.0
	
	match falloff_type:
		0:
			t = normalized_distance
		1:
			t = smoothstep(0.0, 1.0, normalized_distance)
		2:
			t = sqrt(normalized_distance)
		3:
			t = normalized_distance * normalized_distance
	
	return lerp(start_height, end_height, t)
