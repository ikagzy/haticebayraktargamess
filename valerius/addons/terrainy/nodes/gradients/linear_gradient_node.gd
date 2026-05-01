@tool
class_name LinearGradientNode
extends GradientNode

const GradientNode = preload("res://addons/terrainy/nodes/gradients/gradient_node.gd")


@export var direction: Vector2 = Vector2(1, 0):
	set(value):
		direction = value.normalized()
		_commit_parameter_change()

@export_enum("Linear", "Smooth", "Ease In", "Ease Out") var interpolation: int = 1:
	set(value):
		interpolation = value
		_commit_parameter_change()

func get_height_at(world_pos: Vector3) -> float:
	var local_pos = to_local(world_pos)
	var pos_2d = Vector2(local_pos.x, local_pos.z)
	
	var projected = pos_2d.dot(direction)
	
	var radius = influence_size.x
	var t = (projected + radius) / (radius * 2.0)
	t = clamp(t, 0.0, 1.0)
	
	match interpolation:
		0:
			pass
		1:
			t = smoothstep(0.0, 1.0, t)
		2:
			t = t * t
		3:
			t = 1.0 - (1.0 - t) * (1.0 - t)
	
	return lerp(start_height, end_height, t)
	
	return lerp(start_height, end_height, t)
