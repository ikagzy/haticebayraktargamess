@tool
class_name TerrainTextureLayer
extends Resource


signal layer_changed

@export var layer_name: String = "New Layer":
	set(value):
		layer_name = value
		layer_changed.emit()

@export_group("Textures")
@export var albedo_texture: Texture2D:
	set(value):
		albedo_texture = value
		layer_changed.emit()

@export var albedo_color: Color = Color.WHITE:
	set(value):
		albedo_color = value
		layer_changed.emit()

@export var normal_texture: Texture2D:
	set(value):
		normal_texture = value
		layer_changed.emit()

@export_range(0.0, 2.0) var normal_strength: float = 1.0:
	set(value):
		normal_strength = value
		layer_changed.emit()

@export var roughness_texture: Texture2D:
	set(value):
		roughness_texture = value
		layer_changed.emit()

@export_range(0.0, 1.0) var roughness: float = 1.0:
	set(value):
		roughness = value
		layer_changed.emit()

@export var metallic_texture: Texture2D:
	set(value):
		metallic_texture = value
		layer_changed.emit()

@export_range(0.0, 1.0) var metallic: float = 0.0:
	set(value):
		metallic = value
		layer_changed.emit()

@export var ao_texture: Texture2D:
	set(value):
		ao_texture = value
		layer_changed.emit()

@export_range(0.0, 1.0) var ao_strength: float = 1.0:
	set(value):
		ao_strength = value
		layer_changed.emit()

@export_group("UV Settings")
@export var uv_scale: Vector2 = Vector2(10.0, 10.0):
	set(value):
		uv_scale = value
		layer_changed.emit()

@export var uv_offset: Vector2 = Vector2.ZERO:
	set(value):
		uv_offset = value
		layer_changed.emit()

@export_group("Height Blending")
@export var height_min: float = -1000.0:
	set(value):
		height_min = value
		layer_changed.emit()

@export var height_max: float = 1000.0:
	set(value):
		height_max = value
		layer_changed.emit()

@export var height_blend_curve: Curve:
	set(value):
		if height_blend_curve and height_blend_curve.changed.is_connected(_on_curve_changed):
			height_blend_curve.changed.disconnect(_on_curve_changed)
		height_blend_curve = value
		if height_blend_curve:
			height_blend_curve.changed.connect(_on_curve_changed)
		layer_changed.emit()

@export var height_falloff: float = 5.0:
	set(value):
		height_falloff = max(0.0, value)
		layer_changed.emit()

@export_group("Slope Blending")
@export_range(0.0, 90.0) var slope_min: float = 0.0:
	set(value):
		slope_min = clamp(value, 0.0, 90.0)
		layer_changed.emit()

@export_range(0.0, 90.0) var slope_max: float = 90.0:
	set(value):
		slope_max = clamp(value, 0.0, 90.0)
		layer_changed.emit()

@export var slope_blend_curve: Curve:
	set(value):
		if slope_blend_curve and slope_blend_curve.changed.is_connected(_on_curve_changed):
			slope_blend_curve.changed.disconnect(_on_curve_changed)
		slope_blend_curve = value
		if slope_blend_curve:
			slope_blend_curve.changed.connect(_on_curve_changed)
		layer_changed.emit()

@export_range(0.0, 45.0) var slope_falloff: float = 10.0:
	set(value):
		slope_falloff = value
		layer_changed.emit()

@export_group("Layer Settings")
@export_range(0.0, 1.0) var layer_strength: float = 1.0:
	set(value):
		layer_strength = value
		layer_changed.emit()

@export_enum("Normal", "Add", "Multiply") var blend_mode: int = 0:
	set(value):
		blend_mode = value
		layer_changed.emit()

func _on_curve_changed() -> void:
	layer_changed.emit()

func calculate_blend_weight(height: float, slope_angle: float) -> float:
	var weight: float = 1.0
	
	if height < height_min - height_falloff:
		weight = 0.0
	elif height < height_min + height_falloff:
		var t = (height - (height_min - height_falloff)) / (height_falloff * 2.0)
		weight *= smoothstep(0.0, 1.0, t)
		if height_blend_curve:
			weight *= height_blend_curve.sample(t)
	
	if height > height_max + height_falloff:
		weight = 0.0
	elif height > height_max - height_falloff:
		var t = ((height_max + height_falloff) - height) / (height_falloff * 2.0)
		weight *= smoothstep(0.0, 1.0, t)
		if height_blend_curve:
			weight *= height_blend_curve.sample(1.0 - t)
	
	if slope_angle < slope_min - slope_falloff:
		weight = 0.0
	elif slope_angle < slope_min + slope_falloff:
		var t = (slope_angle - (slope_min - slope_falloff)) / (slope_falloff * 2.0)
		weight *= smoothstep(0.0, 1.0, t)
		if slope_blend_curve:
			weight *= slope_blend_curve.sample(t)
	
	if slope_angle > slope_max + slope_falloff:
		weight = 0.0
	elif slope_angle > slope_max - slope_falloff:
		var t = ((slope_max + slope_falloff) - slope_angle) / (slope_falloff * 2.0)
		weight *= smoothstep(0.0, 1.0, t)
		if slope_blend_curve:
			weight *= slope_blend_curve.sample(1.0 - t)
	
	return weight * layer_strength

func smoothstep(edge0: float, edge1: float, x: float) -> float:
	var t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)
