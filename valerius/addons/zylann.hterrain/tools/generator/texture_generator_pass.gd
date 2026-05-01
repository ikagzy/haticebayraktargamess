
var debug_name := ""
var clear := false
var texture : Texture = null
var shader : Shader = null
var params = null
var padding := 0
var iterations := 1
var output := false
var metadata = null
var tile_pos := Vector2()

func duplicate():
	var p = get_script().new()
	p.debug_name = debug_name
	p.clear = clear
	p.texture = texture
	p.shader = shader
	p.params = params
	p.padding = padding
	p.iterations = iterations
	p.output = output
	p.metadata = metadata
	p.tile_pos = tile_pos
	return p
