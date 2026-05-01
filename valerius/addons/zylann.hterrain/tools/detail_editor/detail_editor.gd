@tool
extends Control

const HTerrain = preload("../../hterrain.gd")
const HTerrainData = preload("../../hterrain_data.gd")
const HTerrainDetailLayer = preload("../../hterrain_detail_layer.gd")
const HT_ImageFileCache = preload("../../util/image_file_cache.gd")
const HT_EditorUtil = preload("../util/editor_util.gd")
const HT_Logger = preload("../../util/logger.gd")

const PLACEHOLDER_ICON_TEXTURE = "res://addons/zylann.hterrain/tools/icons/icon_grass.svg"
const DETAIL_LAYER_ICON_TEXTURE = \
	"res://addons/zylann.hterrain/tools/icons/icon_detail_layer_node.svg"

signal detail_selected(index)
signal detail_list_changed

@onready var _item_list : ItemList = $ItemList
@onready var _confirmation_dialog : ConfirmationDialog = $ConfirmationDialog

var _terrain : HTerrain = null
var _dialog_target := -1
var _undo_redo_manager : EditorUndoRedoManager
var _image_cache : HT_ImageFileCache
var _logger = HT_Logger.get_for(self)


func set_terrain(terrain):
	if _terrain == terrain:
		return
	_terrain = terrain
	_update_list()


func set_undo_redo(ur: EditorUndoRedoManager):
	assert(ur != null)
	_undo_redo_manager = ur


func set_image_cache(image_cache: HT_ImageFileCache):
	_image_cache = image_cache


func set_layer_index(i: int):
	_item_list.select(i, true)


func _update_list():
	_item_list.clear()
	
	if _terrain == null:
		return
	
	var layer_nodes = _terrain.get_detail_layers()
	var layer_nodes_by_index := {}
	for layer in layer_nodes:
		if not layer_nodes_by_index.has(layer.layer_index):
			layer_nodes_by_index[layer.layer_index] = []
		layer_nodes_by_index[layer.layer_index].append(layer.name)

	var data = _terrain.get_data()
	if data != null:
		var layer_count = data.get_map_count(HTerrainData.CHANNEL_DETAIL)
		var placeholder_icon = HT_EditorUtil.load_texture(PLACEHOLDER_ICON_TEXTURE, _logger)
		
		for i in layer_count:
			_item_list.add_item(str("Map ", i), placeholder_icon)
			
			if layer_nodes_by_index.has(i):
				var names := ", ".join(PackedStringArray(layer_nodes_by_index[i]))
				if len(names) == 1:
					_item_list.set_item_tooltip(i, "Used by " + names)
				else:
					_item_list.set_item_tooltip(i, "Used by " + names)
				_item_list.set_item_custom_bg_color(i, Color(0, 0, 0, 0))
			else:
				_item_list.set_item_custom_bg_color(i, Color(1.0, 0.2, 0.2, 0.3))
				_item_list.set_item_tooltip(i, "This map isn't used by any layer. " \
					+ "Add a HTerrainDetailLayer node as child of the terrain.")


func _on_Add_pressed():
	_add_layer()


func _on_Remove_pressed():
	var selected = _item_list.get_selected_items()
	if len(selected) == 0:
		return
	_dialog_target = _item_list.get_selected_items()[0]
	_confirmation_dialog.title = "Removing detail map {0}".format([_dialog_target])
	_confirmation_dialog.popup_centered()


func _on_ConfirmationDialog_confirmed():
	_remove_layer(_dialog_target)


func _add_layer():
	assert(_terrain != null)
	assert(_terrain.get_data() != null)
	assert(_undo_redo_manager != null)
	var terrain_data : HTerrainData = _terrain.get_data()

	var node := HTerrainDetailLayer.new()
	var detail_layer_icon := HT_EditorUtil.load_texture(DETAIL_LAYER_ICON_TEXTURE, _logger)
	node.set_meta("_editor_icon", detail_layer_icon)
	node.name = "HTerrainDetailLayer"
	var map_index := terrain_data._edit_add_map(HTerrainData.CHANNEL_DETAIL)
	var map_image := terrain_data.get_image(HTerrainData.CHANNEL_DETAIL)
	var map_image_cache_id := _image_cache.save_image(map_image)
	node.layer_index = map_index
	
	var undo_redo := _undo_redo_manager.get_history_undo_redo(
		_undo_redo_manager.get_object_history_id(_terrain))
	
	undo_redo.create_action("Add Detail Layer {0}".format([map_index]))
	
	undo_redo.add_do_method(terrain_data._edit_insert_map_from_image_cache.bind( 
		HTerrainData.CHANNEL_DETAIL, map_index, _image_cache, map_image_cache_id))
	undo_redo.add_do_method(_terrain.add_child.bind(node))
	undo_redo.add_do_property(node, "owner", get_tree().edited_scene_root)
	undo_redo.add_do_method(self._update_list)
	undo_redo.add_do_reference(node)
	
	undo_redo.add_undo_method(_terrain.remove_child.bind(node))
	undo_redo.add_undo_method(
		terrain_data._edit_remove_map.bind(HTerrainData.CHANNEL_DETAIL, map_index))
	undo_redo.add_undo_method(self._update_list)
	
	terrain_data._edit_set_disable_apply_undo(true)
	undo_redo.commit_action()
	terrain_data._edit_set_disable_apply_undo(false)
	
	detail_list_changed.emit()
	
	var index := node.layer_index
	_item_list.select(index)
	detail_selected.emit(index)


func _remove_layer(map_index: int):
	var terrain_data : HTerrainData = _terrain.get_data()
	
	var image := terrain_data.get_image(HTerrainData.CHANNEL_DETAIL, map_index)
	var image_id := _image_cache.save_image(image)
	var nodes = _terrain.get_detail_layers()
	var using_nodes := []
	for node in nodes:
		if node.layer_index == map_index:
			using_nodes.append(node)
	
	var undo_redo := _undo_redo_manager.get_history_undo_redo(
		_undo_redo_manager.get_object_history_id(_terrain))

	undo_redo.create_action("Remove Detail Layer {0}".format([map_index]))
	
	undo_redo.add_do_method(
		terrain_data._edit_remove_map.bind(HTerrainData.CHANNEL_DETAIL, map_index))
	for node in using_nodes:
		undo_redo.add_do_method(_terrain.remove_child.bind(node))
	undo_redo.add_do_method(self._update_list)
	
	undo_redo.add_undo_method(terrain_data._edit_insert_map_from_image_cache.bind(
		HTerrainData.CHANNEL_DETAIL, map_index, _image_cache, image_id))
	for node in using_nodes:
		undo_redo.add_undo_method(_terrain.add_child.bind(node))
		undo_redo.add_undo_property(node, "owner", get_tree().edited_scene_root)
		undo_redo.add_undo_reference(node)
	undo_redo.add_undo_method(self._update_list)
	
	undo_redo.commit_action()
	
	detail_list_changed.emit()


func _on_ItemList_item_selected(index):
	detail_selected.emit(index)


	
