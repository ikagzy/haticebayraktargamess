

@tool
extends Node

const HT_Logger = preload("../../util/logger.gd")
const HT_Util = preload("../../util/util.gd")
const HT_NoBlendShader = preload("./no_blend.gdshader")
const HT_NoBlendRFShader = preload("./no_blend_rf.gdshader")

const UNDO_CHUNK_SIZE = 64

const SHADER_PARAM_SRC_TEXTURE = "u_src_texture"
const SHADER_PARAM_SRC_RECT = "u_src_rect"
const SHADER_PARAM_OPACITY = "u_opacity"

const _API_SHADER_PARAMS = [
	SHADER_PARAM_SRC_TEXTURE,
	SHADER_PARAM_SRC_RECT,
	SHADER_PARAM_OPACITY
]

signal texture_region_changed(rect)

const _hdr_formats = [
	Image.FORMAT_RH,
	Image.FORMAT_RGH,
	Image.FORMAT_RGBH,
	Image.FORMAT_RGBAH
]

const _supported_formats = [
	Image.FORMAT_R8,
	Image.FORMAT_RG8,
	Image.FORMAT_RGB8,
	Image.FORMAT_RGBA8
]


var _viewport : SubViewport
var _viewport_bg_sprite : Sprite2D
var _viewport_brush_sprite : Sprite2D
var _brush_size := 32
var _brush_scale := 1.0
var _brush_position := Vector2()
var _brush_opacity := 1.0
var _brush_texture : Texture
var _last_brush_position := Vector2()
var _brush_material := ShaderMaterial.new()
var _no_blend_material : ShaderMaterial
var _image : Image
var _texture : ImageTexture
var _cmd_paint := false
var _pending_paint_render := false
var _modified_chunks := {}
var _modified_shader_params := {}

var _debug_display : TextureRect
var _logger = HT_Logger.get_for(self)


func _init():
	_viewport = SubViewport.new()
	_viewport.size = Vector2(_brush_size, _brush_size)
	_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	_viewport.transparent_bg = true
	
	_no_blend_material = ShaderMaterial.new()
	_no_blend_material.shader = HT_NoBlendShader
	_viewport_bg_sprite = Sprite2D.new()
	_viewport_bg_sprite.centered = false
	_viewport_bg_sprite.material = _no_blend_material
	_viewport.add_child(_viewport_bg_sprite)
	
	_viewport_brush_sprite = Sprite2D.new()
	_viewport_brush_sprite.centered = true
	_viewport_brush_sprite.material = _brush_material
	_viewport_brush_sprite.position = _viewport.size / 2.0
	_viewport.add_child(_viewport_brush_sprite)
	
	add_child(_viewport)


func set_debug_display(dd: TextureRect):
	_debug_display = dd
	_debug_display.texture = _viewport.get_texture()


func set_image(image: Image, texture: ImageTexture):
	assert((image == null and texture == null) or (image != null and texture != null))
	_image = image
	_texture = texture
	_viewport_bg_sprite.texture = _texture
	_brush_material.set_shader_parameter(SHADER_PARAM_SRC_TEXTURE, _texture)
	if image != null:
		if image.get_format() == Image.FORMAT_RF:
			_no_blend_material.shader = HT_NoBlendRFShader
		else:
			_no_blend_material.shader = HT_NoBlendShader
		if (image.get_format() in _hdr_formats) and image.get_format() != Image.FORMAT_RF:
			push_error("Godot 4.0 does not support HDR viewports for GPU-editing heightmaps! " +
				"Only RF is supported using a bit packing hack.")


func set_brush_size(new_size: int):
	_brush_size = new_size


func get_brush_size() -> int:
	return _brush_size


func set_brush_rotation(rotation: float):
	_viewport_brush_sprite.rotation = rotation


func get_brush_rotation() -> float:
	return _viewport_bg_sprite.rotation


func set_brush_scale(s: float):
	_brush_scale = clampf(s, 0.0, 1.0)


func get_brush_scale() -> float:
	return _viewport_bg_sprite.scale.x


func set_brush_opacity(opacity: float):
	_brush_opacity = clampf(opacity, 0.0, 1.0)


func get_brush_opacity() -> float:
	return _brush_opacity


func set_brush_texture(texture: Texture):
	_viewport_brush_sprite.texture = texture


func set_brush_shader(shader: Shader):
	if _brush_material.shader != shader:
		_brush_material.shader = shader


func set_brush_shader_param(p: String, v):
	assert(not _API_SHADER_PARAMS.has(p))
	_modified_shader_params[p] = true
	_brush_material.set_shader_parameter(p, v)


func clear_brush_shader_params():
	for key in _modified_shader_params:
		_brush_material.set_shader_parameter(key, null)
	_modified_shader_params.clear()


static func _get_size_fit_for_rotation(src_size: Vector2) -> Vector2i:
	var d = int(ceilf(src_size.length()))
	return Vector2i(d, d)


func paint_input(center_pos: Vector2):
	var vp_size := _get_size_fit_for_rotation(Vector2(_brush_size, _brush_size))
	if _viewport.size != vp_size:
		_viewport.size = vp_size
		_viewport_brush_sprite.position = _viewport.size / 2.0

	var brush_pos := (center_pos - _viewport.size * 0.5).round()
	_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	_viewport_bg_sprite.position = -brush_pos
	_brush_position = brush_pos
	_cmd_paint = true
	
	_viewport_brush_sprite.scale = \
		_brush_scale * Vector2(_brush_size, _brush_size) \
		/ Vector2(_viewport_brush_sprite.texture.get_size())

	var rect := Color()
	rect.r = brush_pos.x / _texture.get_width()
	rect.g = brush_pos.y / _texture.get_height()
	rect.b = float(_viewport.size.x) / float(_texture.get_width())
	rect.a = float(_viewport.size.y) / float(_texture.get_height())
	_brush_material.set_shader_parameter(SHADER_PARAM_SRC_RECT, rect)
	_brush_material.set_shader_parameter(SHADER_PARAM_OPACITY, _brush_opacity)


func is_operation_pending() -> bool:
	return _pending_paint_render or _cmd_paint


func commit() -> Dictionary:
	if is_operation_pending():
		_logger.error("Painter commit() was called while an operation is still pending")
	return _commit_modified_chunks()


func has_modified_chunks() -> bool:
	return len(_modified_chunks) > 0


func _process(delta: float):
	if _pending_paint_render:
		_pending_paint_render = false
	
		var viewport_image := _viewport.get_texture().get_image()
		
		if _image.get_format() == Image.FORMAT_RF:
			assert(viewport_image.get_format() == Image.FORMAT_RGBA8)
			viewport_image = Image.create_from_data(
				viewport_image.get_width(), viewport_image.get_height(), false, Image.FORMAT_RF, 
				viewport_image.get_data())
		else:
			viewport_image.convert(_image.get_format())
		
		var brush_pos := _last_brush_position
		
		var dst_x : int = clamp(brush_pos.x, 0, _texture.get_width())
		var dst_y : int = clamp(brush_pos.y, 0, _texture.get_height())
		
		var src_x : int = maxf(-brush_pos.x, 0)
		var src_y : int = maxf(-brush_pos.y, 0)
		var src_w : int = minf(maxf(_viewport.size.x - src_x, 0), _texture.get_width() - dst_x)
		var src_h : int = minf(maxf(_viewport.size.y - src_y, 0), _texture.get_height() - dst_y)
		
		if src_w != 0 and src_h != 0:
			_mark_modified_chunks(dst_x, dst_y, src_w, src_h)
			HT_Util.update_texture_partial(_texture, viewport_image,
				Rect2i(src_x, src_y, src_w, src_h), Vector2i(dst_x, dst_y))
			texture_region_changed.emit(Rect2(dst_x, dst_y, src_w, src_h))
	
	if _cmd_paint:
		_pending_paint_render = true
		_last_brush_position = _brush_position
		_cmd_paint = false


func _mark_modified_chunks(bx: int, by: int, bw: int, bh: int):
	var cs := UNDO_CHUNK_SIZE
	
	var cmin_x := bx / cs
	var cmin_y := by / cs
	var cmax_x := (bx + bw - 1) / cs + 1
	var cmax_y := (by + bh - 1) / cs + 1
	
	for cy in range(cmin_y, cmax_y):
		for cx in range(cmin_x, cmax_x):
			_modified_chunks[Vector2(cx, cy)] = true


func _commit_modified_chunks() -> Dictionary:
	var time_before := Time.get_ticks_msec()
	
	var cs := UNDO_CHUNK_SIZE
	var chunks_positions := []
	var chunks_initial_data := []
	var chunks_final_data := []

	
	var final_image := _texture.get_image()
	for cpos in _modified_chunks:
		var cx : int = cpos.x
		var cy : int = cpos.y
		
		var x := cx * cs
		var y := cy * cs
		var w : int = mini(cs, _image.get_width() - x)
		var h : int = mini(cs, _image.get_height() - y)
		
		var rect := Rect2i(x, y, w, h)
		var initial_data := _image.get_region(rect)
		var final_data := final_image.get_region(rect)
		
		chunks_positions.append(cpos)
		chunks_initial_data.append(initial_data)
		chunks_final_data.append(final_data)
		
		_image.blit_rect(final_image, rect, rect.position)
	
	_modified_chunks.clear()
	
	var time_spent := Time.get_ticks_msec() - time_before
	_logger.debug("Spent {0} ms to commit paint operation".format([time_spent]))
	
	return {
		"chunk_positions": chunks_positions,
		"chunk_initial_datas": chunks_initial_data,
		"chunk_final_datas": chunks_final_data
	}




