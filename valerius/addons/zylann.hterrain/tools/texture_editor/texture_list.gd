

@tool
extends ScrollContainer

const HT_TextureListItemScene = preload("./texture_list_item.tscn")
const HT_TextureListItem = preload("./texture_list_item.gd")

signal item_selected(index)
signal item_activated(index)

@onready var _container : Container = $Container


var _selected_item := -1




func add_item(text: String, texture: Texture, texture_layer: int = 0):
	var item : HT_TextureListItem = HT_TextureListItemScene.instantiate()
	_container.add_child(item)
	item.set_text(text)
	item.set_texture(texture, texture_layer)


func get_item_count() -> int:
	return _container.get_child_count()


func set_item_texture(index: int, tex: Texture, layer: int = 0):
	var child : HT_TextureListItem = _container.get_child(index)
	child.set_texture(tex, layer)


func get_selected_item() -> int:
	return _selected_item


func clear():
	for i in _container.get_child_count():
		var child = _container.get_child(i)
		if child is Control:
			child.queue_free()
	_selected_item = -1


func _on_item_selected(item: HT_TextureListItem):
	_selected_item = item.get_index()
	for i in _container.get_child_count():
		var child = _container.get_child(i)
		if child is HT_TextureListItem and child != item:
			child.set_selected(false, false)
	item_selected.emit(_selected_item)


func _on_item_activated(item: HT_TextureListItem):
	item_activated.emit(item.get_index())


func _draw():
	draw_rect(get_rect(), Color(0,0,0,0.3))
