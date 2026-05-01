@tool
class_name HillNode
extends PrimitiveNode

const PrimitiveNode = preload("res://addons/terrainy/nodes/primitives/primitive_node.gd")


@export_enum("Smooth", "Cone", "Dome") var shape: int = 0:
	set(value):
		shape = value
		parameters_changed.emit()

func get_height_at(world_pos: Vector3) -> float:
	var local_pos = to_local(world_pos)
	return get_height_at_safe(world_pos, local_pos)

func get_height_at_safe(world_pos: Vector3, local_pos: Vector3) -> float:
	var distance_2d = Vector2(local_pos.x, local_pos.z).length()
	var radius = influence_size.x
	
	if distance_2d >= radius:
		return 0.0
	
	var normalized_distance = distance_2d / radius
	var height_multiplier = 0.0
	
	match shape:
		0:
			height_multiplier = cos(normalized_distance * PI * 0.5)
			height_multiplier = height_multiplier * height_multiplier
		1:
			height_multiplier = 1.0 - normalized_distance
		2:
			height_multiplier = sqrt(1.0 - normalized_distance * normalized_distance)
	
	return height * height_multiplier
