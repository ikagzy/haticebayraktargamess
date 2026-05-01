

@tool


static func create_open_file_dialog() -> ConfirmationDialog:
	var d
	if Engine.is_editor_hint():
		d = ClassDB.instantiate(&"EditorFileDialog")
		d.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
		d.access = EditorFileDialog.ACCESS_RESOURCES
	else:
		d = FileDialog.new()
		d.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		d.access = FileDialog.ACCESS_RESOURCES
	d.unresizable = false
	return d


static func create_open_dir_dialog() -> ConfirmationDialog:
	var d
	if Engine.is_editor_hint():
		d = ClassDB.instantiate(&"EditorFileDialog")
		d.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
		d.access = EditorFileDialog.ACCESS_RESOURCES
	else:
		d = FileDialog.new()
		d.file_mode = FileDialog.FILE_MODE_OPEN_DIR
		d.access = FileDialog.ACCESS_RESOURCES
	d.unresizable = false
	return d


static func create_open_image_dialog() -> ConfirmationDialog:
	var d = create_open_file_dialog()
	_add_image_filters(d)
	return d


static func create_open_texture_dialog() -> ConfirmationDialog:
	var d = create_open_file_dialog()
	_add_texture_filters(d)
	return d


static func create_open_texture_array_dialog() -> ConfirmationDialog:
	var d = create_open_file_dialog()
	_add_texture_array_filters(d)
	return d


static func _add_image_filters(file_dialog):
	file_dialog.add_filter("*.png ; PNG files")
	file_dialog.add_filter("*.jpg ; JPG files")


static func _add_texture_filters(file_dialog):
	_add_image_filters(file_dialog)
	file_dialog.add_filter("*.ctex ; CompressedTexture files")
	file_dialog.add_filter("*.packed_tex ; HTerrainPackedTexture files")


static func _add_texture_array_filters(file_dialog):
	_add_image_filters(file_dialog)
	file_dialog.add_filter("*.ctexarray ; TextureArray files")
	file_dialog.add_filter("*.packed_texarr ; HTerrainPackedTextureArray files")


static func load_texture(path: String, logger) -> Texture:
	var tex : Texture = load(path)
	if tex != null:
		return tex
	logger.error(str("Failed to load texture ", path, ", attempting to load manually"))
	var im := Image.new()
	var err = im.load(path)
	if err != OK:
		logger.error(str("Failed to load image ", path))
		return null
	var itex := ImageTexture.create_from_image(im)
	return itex

