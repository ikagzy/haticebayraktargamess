@tool
class_name MountainRangeNode
extends LandscapeNode

const LandscapeNode = preload("res://addons/terrainy/nodes/landscapes/landscape_node.gd")


@export var ridge_sharpness: float = 0.5:
	set(value):
		ridge_sharpness = clamp(value, 0.1, 2.0)
		parameters_changed.emit()

@export var peak_noise: FastNoiseLite:
	set(value):
		peak_noise = value
		if peak_noise and not peak_noise.changed.is_connected(_on_noise_changed):
			peak_noise.changed.connect(_on_noise_changed)
		parameters_changed.emit()

@export var detail_noise: FastNoiseLite:
	set(value):
		detail_noise = value
		if detail_noise and not detail_noise.changed.is_connected(_on_noise_changed):
			detail_noise.changed.connect(_on_noise_changed)
		parameters_changed.emit()

func _ready() -> void:
	if not peak_noise:
		peak_noise = FastNoiseLite.new()
		peak_noise.seed = randi()
		peak_noise.frequency = 0.008
		peak_noise.fractal_octaves = 2
	
	if not detail_noise:
		detail_noise = FastNoiseLite.new()
		detail_noise.seed = randi() + 1000
		detail_noise.frequency = 0.05
		detail_noise.fractal_octaves = 4

func get_height_at(world_pos: Vector3) -> float:
	var local_pos = to_local(world_pos)
	return get_height_at_safe(world_pos, local_pos)

func get_height_at_safe(world_pos: Vector3, local_pos: Vector3) -> float:
	var distance_2d = Vector2(local_pos.x, local_pos.z).length()
	
	var radius = influence_size.x
	
	if distance_2d >= radius:
		return 0.0
	
	var perpendicular = Vector2(-direction.y, direction.x)
	var lateral_distance = abs(Vector2(local_pos.x, local_pos.z).dot(perpendicular))
	
	var along_ridge = Vector2(local_pos.x, local_pos.z).dot(direction)
	
	var ridge_falloff = 1.0 - pow(lateral_distance / radius, ridge_sharpness)
	ridge_falloff = max(0.0, ridge_falloff)
	
	var result_height = height * ridge_falloff
	
	if peak_noise:
		var peak_variation = peak_noise.get_noise_1d(along_ridge)
		result_height *= 0.7 + peak_variation * 0.3
	
	if detail_noise:
		var detail = detail_noise.get_noise_2d(world_pos.x, world_pos.z)
		result_height += result_height * detail * 0.2
	
	return result_height
