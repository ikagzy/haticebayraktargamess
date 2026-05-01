@tool
class_name VoronoiNode
extends NoiseNode

const NoiseNode = preload("res://addons/terrainy/nodes/basic/noise_node.gd")


@export_enum("F1", "F2", "F2 - F1", "Cells") var distance_mode: int = 0:
	set(value):
		distance_mode = value
		parameters_changed.emit()

func _ready() -> void:
	if not noise:
		noise = FastNoiseLite.new()
		noise.seed = randi()
		noise.noise_type = FastNoiseLite.TYPE_CELLULAR
		noise.cellular_distance_function = FastNoiseLite.DISTANCE_EUCLIDEAN
		noise.cellular_return_type = FastNoiseLite.RETURN_CELL_VALUE

func get_height_at(world_pos: Vector3) -> float:
	var local_pos = to_local(world_pos)
	var distance_2d = Vector2(local_pos.x, local_pos.z).length()
	
	var radius = influence_size.x
	
	if distance_2d >= radius:
		return 0.0
	
	if not noise:
		return 0.0
	
	match distance_mode:
		0:
			noise.cellular_return_type = FastNoiseLite.RETURN_DISTANCE
		1:
			noise.cellular_return_type = FastNoiseLite.RETURN_DISTANCE2
		2:
			noise.cellular_return_type = FastNoiseLite.RETURN_DISTANCE2_ADD
		3:
			noise.cellular_return_type = FastNoiseLite.RETURN_CELL_VALUE
	
	var voronoi_value = noise.get_noise_2d(world_pos.x, world_pos.z)
	
	var height = (voronoi_value + 1.0) * 0.5 * amplitude
	
	return height
