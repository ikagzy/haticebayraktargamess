@tool
extends EditorFileDialog


func _init():
	file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	add_filter("*.png ; PNG files")
	add_filter("*.jpg ; JPG files")
	unresizable = false
	access = EditorFileDialog.ACCESS_RESOURCES
	close_requested.connect(call_deferred.bind("_on_close"))


func _on_close():
	var cons = get_signal_connection_list("file_selected")
	for con in cons:
		file_selected.disconnect(con.callable)

