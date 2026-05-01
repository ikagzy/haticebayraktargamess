@tool
class_name TerrainFeatureNode
extends Node3D

const HeightmapModifierProcessor = preload("res://addons/terrainy/nodes/heightmap_modifier_processor.gd")


signal parameters_changed

const INFLUENCE_WEIGHT_THRESHOLD = 0.001
const GIZMO_MANIPULATION_TIMEOUT_SEC = 5.0
const MIN_INFLUENCE_SIZE = 0.01

enum InfluenceShape {
	CIRCLE,
	RECTANGLE,
	ELLIPSE
}

enum SmoothingMode {
	NONE,
	LIGHT,
	MEDIUM,
	HEAVY
}

enum BlendMode {
	ADD,
	SUBTRACT,
	MAX,
	MIN,
	MULTIPLY,
	AVERAGE
}

@export var influence_shape: InfluenceShape = InfluenceShape.CIRCLE:
	set(value):
		influence_shape = value
		_commit_parameter_change()

@export var influence_size: Vector2 = Vector2(50.0, 50.0):
	set(value):
		influence_size = value
		_commit_parameter_change()

@export_range(0.0, 1.0) var edge_falloff: float = 0.3:
	set(value):
		edge_falloff = value
		_commit_parameter_change()

@export_enum("Add", "Subtract", "Max", "Min", "Multiply", "Average") var blend_mode: int = 0:
	set(value):
		blend_mode = value
		_commit_parameter_change()

@export_range(0.0, 2.0) var strength: float = 1.0:
	set(value):
		strength = value
		_commit_parameter_change()

@export_group("Modifiers")

@export var smoothing: SmoothingMode = SmoothingMode.NONE:
	set(value):
		smoothing = value
		_smoothing_cache.clear()
		_commit_parameter_change()

@export_range(0.5, 10.0) var smoothing_radius: float = 2.0:
	set(value):
		smoothing_radius = value
		_smoothing_cache.clear()
		_commit_parameter_change()

@export var enable_terracing: bool = false:
	set(value):
		enable_terracing = value
		_commit_parameter_change()

@export_range(2, 20) var terrace_levels: int = 5:
	set(value):
		terrace_levels = value
		_commit_parameter_change()

@export_range(0.0, 1.0) var terrace_smoothness: float = 0.2:
	set(value):
		terrace_smoothness = value
		_commit_parameter_change()

@export var enable_min_clamp: bool = false:
	set(value):
		enable_min_clamp = value
		_commit_parameter_change()

@export var min_height: float = 0.0:
	set(value):
		min_height = value
		_commit_parameter_change()

@export var enable_max_clamp: bool = false:
	set(value):
		enable_max_clamp = value
		_commit_parameter_change()

@export var max_height: float = 100.0:
	set(value):
		max_height = value
		_commit_parameter_change()

var _smoothing_cache: Dictionary = {}

var _heightmap_dirty: bool = true

static var _gpu_modifier_processor: HeightmapModifierProcessor = null
static var _feature_reference_count: int = 0

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_feature_reference_count -= 1
		if _feature_reference_count <= 0 and _gpu_modifier_processor:
			if _gpu_modifier_processor.has_method("cleanup"):
				_gpu_modifier_processor.cleanup()
			_gpu_modifier_processor = null
			_feature_reference_count = 0

func _ready() -> void:
	_feature_reference_count += 1

static func _get_gpu_modifier_processor() -> HeightmapModifierProcessor:
	if not _gpu_modifier_processor:
		_gpu_modifier_processor = HeightmapModifierProcessor.new()
		if not _gpu_modifier_processor.is_available():
			push_warning("[TerrainFeatureNode] GPU modifiers unavailable, will use CPU fallback")
	return _gpu_modifier_processor

func get_height_at(world_pos: Vector3) -> float:
	return 0.0

func generate_heightmap(resolution: Vector2i, terrain_bounds: Rect2) -> Image:
	var start_time = Time.get_ticks_msec()
	
	var heightmap = Image.create(resolution.x, resolution.y, false, Image.FORMAT_RF)
	
	var step = terrain_bounds.size / Vector2(resolution - Vector2i.ONE)
	
	for y in range(resolution.y):
		for x in range(resolution.x):
			var world_x = terrain_bounds.position.x + (x * step.x)
			var world_z = terrain_bounds.position.y + (y * step.y)
			var world_pos = Vector3(world_x, 0, world_z)
			
			var height = get_height_at(world_pos)
			
			heightmap.set_pixel(x, y, Color(height, 0, 0, 1))
	
	if _has_any_modifiers():
		var processor = _get_gpu_modifier_processor()
		if processor and processor.is_available():
			var modified = processor.apply_modifiers(
				heightmap,
				int(smoothing),
				smoothing_radius,
				enable_terracing,
				terrace_levels,
				terrace_smoothness,
				enable_min_clamp,
				min_height,
				enable_max_clamp,
				max_height
			)
			if modified:
				heightmap = modified
			else:
				_apply_modifiers_cpu(heightmap, terrain_bounds)
		else:
			_apply_modifiers_cpu(heightmap, terrain_bounds)
	
	_heightmap_dirty = false
	
	var elapsed = Time.get_ticks_msec() - start_time
	if Engine.is_editor_hint():
		print("[%s] Generated %dx%d heightmap in %d ms" % [name, resolution.x, resolution.y, elapsed])
	
	return heightmap

func _has_any_modifiers() -> bool:
	return smoothing != SmoothingMode.NONE or \
		   enable_terracing or \
		   enable_min_clamp or \
		   enable_max_clamp

func _apply_modifiers_cpu(heightmap: Image, terrain_bounds: Rect2) -> void:
	var resolution = Vector2i(heightmap.get_width(), heightmap.get_height())
	var step = terrain_bounds.size / Vector2(resolution - Vector2i.ONE)
	
	for y in range(resolution.y):
		for x in range(resolution.x):
			var world_x = terrain_bounds.position.x + (x * step.x)
			var world_z = terrain_bounds.position.y + (y * step.y)
			var world_pos = Vector3(world_x, 0, world_z)
			
			var height = heightmap.get_pixel(x, y).r
			height = _apply_modifiers(world_pos, height)
			heightmap.set_pixel(x, y, Color(height, 0, 0, 1))

func mark_dirty() -> void:
	_heightmap_dirty = true

func is_dirty() -> bool:
	return _heightmap_dirty

func get_height_at_safe(world_pos: Vector3, local_pos: Vector3) -> float:
	return get_height_at(world_pos)

func get_influence_weight(world_pos: Vector3) -> float:
	if not is_inside_tree():
		return 0.0
	
	var local_pos = to_local(world_pos)
	var local_pos_2d = Vector2(local_pos.x, local_pos.z)
	
	var distance: float
	var max_distance: float
	
	match influence_shape:
		InfluenceShape.CIRCLE:
			distance = local_pos_2d.length()
			max_distance = max(influence_size.x, MIN_INFLUENCE_SIZE)
		
		InfluenceShape.RECTANGLE:
			var half_size = influence_size * 0.5
			half_size = half_size.max(Vector2(MIN_INFLUENCE_SIZE, MIN_INFLUENCE_SIZE))
			if abs(local_pos_2d.x) > half_size.x or abs(local_pos_2d.y) > half_size.y:
				return 0.0
			
			var dist_x = half_size.x - abs(local_pos_2d.x)
			var dist_y = half_size.y - abs(local_pos_2d.y)
			distance = min(dist_x, dist_y)
			max_distance = min(half_size.x, half_size.y)
		
		InfluenceShape.ELLIPSE:
			var safe_size_x = max(influence_size.x, MIN_INFLUENCE_SIZE)
			var safe_size_y = max(influence_size.y, MIN_INFLUENCE_SIZE)
			var normalized = Vector2(
				local_pos_2d.x / safe_size_x,
				local_pos_2d.y / safe_size_y
			)
			distance = normalized.length()
			max_distance = 1.0
			
			if distance >= max_distance:
				return 0.0
	
	if influence_shape == InfluenceShape.CIRCLE or influence_shape == InfluenceShape.ELLIPSE:
		if distance >= max_distance:
			return 0.0
	
	if edge_falloff <= 0.0:
		return 1.0
	
	var falloff_distance: float
	if influence_shape == InfluenceShape.RECTANGLE:
		falloff_distance = max_distance * edge_falloff
		if distance > falloff_distance:
			return 1.0
		var t = distance / falloff_distance
		return smoothstep(0.0, 1.0, t)
	else:
		var falloff_start = max_distance * (1.0 - edge_falloff)
		if distance < falloff_start:
			return 1.0
		var t = (distance - falloff_start) / (max_distance - falloff_start)
		return 1.0 - smoothstep(0.0, 1.0, t)

func get_blended_height_at(world_pos: Vector3) -> float:
	var height = get_height_at(world_pos)
	
	height = _apply_modifiers(world_pos, height)
	
	var weight = get_influence_weight(world_pos)
	return height * weight * strength

func _apply_modifiers(world_pos: Vector3, base_height: float) -> float:
	var height = base_height
	
	if smoothing != SmoothingMode.NONE:
		height = _apply_smoothing(world_pos, height)
	
	if enable_terracing:
		height = _apply_terracing(height)
	
	if enable_min_clamp:
		height = max(height, min_height)
	if enable_max_clamp:
		height = min(height, max_height)
	
	return height

func _apply_smoothing(world_pos: Vector3, center_height: float) -> float:
	var grid_size = smoothing_radius * 0.5
	var cache_key = Vector3i(
		int(world_pos.x / grid_size),
		0,
		int(world_pos.z / grid_size)
	)
	
	if _smoothing_cache.has(cache_key):
		return _smoothing_cache[cache_key]
	
	var sample_count: int
	var sample_radius: float
	
	match smoothing:
		SmoothingMode.LIGHT:
			sample_count = 4
			sample_radius = smoothing_radius * 0.5
		SmoothingMode.MEDIUM:
			sample_count = 8
			sample_radius = smoothing_radius
		SmoothingMode.HEAVY:
			sample_count = 12
			sample_radius = smoothing_radius * 1.5
		_:
			return center_height
	
	var total_height = center_height
	var total_weight = 1.0
	
	for i in range(sample_count):
		var angle = (i / float(sample_count)) * TAU
		var offset = Vector3(
			cos(angle) * sample_radius,
			0,
			sin(angle) * sample_radius
		)
		var sample_pos = world_pos + offset
		
		var sample_height = get_height_at(sample_pos)
		
		var weight = 1.0 - (offset.length() / (sample_radius * 1.5))
		weight = max(0.0, weight)
		
		total_height += sample_height * weight
		total_weight += weight
	
	var smoothed_height = total_height / total_weight
	_smoothing_cache[cache_key] = smoothed_height
	
	return smoothed_height

func _apply_terracing(height: float) -> float:
	if terrace_levels <= 1:
		return height
	
	var normalized_height = height / 100.0
	
	var level = floor(normalized_height * terrace_levels)
	var level_height = level / float(terrace_levels)
	
	if terrace_smoothness > 0.0:
		var next_level_height = (level + 1.0) / float(terrace_levels)
		var t = (normalized_height * terrace_levels) - level
		t = smoothstep(0.0, 1.0, t / terrace_smoothness)
		level_height = lerp(level_height, next_level_height, t)
	
	return level_height * 100.0

func get_influence_aabb() -> AABB:
	var half_size: Vector2
	if influence_shape == InfluenceShape.CIRCLE:
		half_size = Vector2(influence_size.x, influence_size.x)
	else:
		half_size = influence_size * 0.5
	
	return AABB(
		global_position + Vector3(-half_size.x, -100, -half_size.y),
		Vector3(half_size.x * 2.0, 200, half_size.y * 2.0)
	)

func _is_gizmo_manipulating() -> bool:
	var is_manipulating = get_meta("_gizmo_manipulating", false)
	
	if is_manipulating:
		var last_gizmo_time = get_meta("_gizmo_manipulation_time", 0.0)
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_gizmo_time > GIZMO_MANIPULATION_TIMEOUT_SEC:
			set_meta("_gizmo_manipulating", false)
			return false
	
	return is_manipulating

func _commit_parameter_change() -> void:
	_heightmap_dirty = true
	if not _is_gizmo_manipulating():
		parameters_changed.emit()
		if Engine.is_editor_hint():
			print("[%s] parameters_changed emitted" % name)

func validate_configuration() -> bool:
	var is_valid = true
	
	if influence_size.x < MIN_INFLUENCE_SIZE or influence_size.y < MIN_INFLUENCE_SIZE:
		push_warning("[%s] Influence size too small, clamping to minimum" % name)
		influence_size = influence_size.max(Vector2(MIN_INFLUENCE_SIZE, MIN_INFLUENCE_SIZE))
		is_valid = false
	
	if strength <= 0.0:
		push_warning("[%s] Strength is zero or negative, feature will have no effect" % name)
	
	if "height" in self:
		var height_value = get("height")
		if abs(height_value) < 0.001:
			push_warning("[%s] Height is near zero, feature may not be visible" % name)
	
	return is_valid
