@tool
extends ConfirmationDialog

var lod: int = 0
var description: String = ""


func _ready() -> void:
	set_unparent_when_invisible(true)
	about_to_popup.connect(_on_about_to_popup)
	visibility_changed.connect(_on_visibility_changed)
	%LodBox.value_changed.connect(_on_lod_box_value_changed)


func _on_about_to_popup() -> void:
	lod = %LodBox.value


func _on_visibility_changed() -> void:
	if visible:
		%DescriptionLabel.text = description


func _on_lod_box_value_changed(p_value: float) -> void:
	lod = %LodBox.value
