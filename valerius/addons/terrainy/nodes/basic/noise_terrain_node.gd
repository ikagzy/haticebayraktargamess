@tool
class_name PerlinNoiseNode
extends NoiseNode

const NoiseNode = preload("res://addons/terrainy/nodes/basic/noise_node.gd")


func _ready() -> void:
	if not noise:
		noise = FastNoiseLite.new()
		noise.seed = randi()
		noise.frequency = 0.01
		noise.noise_type = FastNoiseLite.TYPE_PERLIN

func get_height_at(world_pos: Vector3) -> float:
	if not noise:
		return 0.0
	
	var noise_value = noise.get_noise_2d(world_pos.x, world_pos.z)
	return (noise_value + 1.0) * 0.5 * amplitude

func get_height_at_safe(world_pos: Vector3, local_pos: Vector3) -> float:
	return get_height_at(world_pos)
