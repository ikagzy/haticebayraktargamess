

@tool
extends Control

const HT_Util = preload("../../util/util.gd")


func _notification(what: int):
	if HT_Util.is_in_edited_scene(self):
		return
	if is_inside_tree() and what == Control.NOTIFICATION_VISIBILITY_CHANGED:
		call_deferred("_fit_to_contents")


func _fit_to_contents():
	var dialog : Window = get_parent()
	for child in dialog.get_children():
		if child is Container:
			var child_rect : Rect2 = child.get_global_rect()
			var dialog_rect := Rect2(Vector2(), dialog.size)
			if not dialog_rect.encloses(child_rect):
				var margin : Vector2 = child.get_rect().position
				dialog.min_size = child_rect.size + margin * 2.0



