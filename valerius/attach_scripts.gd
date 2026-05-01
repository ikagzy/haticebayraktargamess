extends SceneTree

func _init():
	var packed_scene = load("res://kale.tscn")
	if not packed_scene:
		print("ERROR: Could not load kale.tscn")
		quit()
		return
		
	var scene = packed_scene.instantiate()

	var raf_script = load("res://parlayan_raf.gd")
	var keypad_script = load("res://keypad_sistemi.gd")

	var shelf_mapping = {
		"Shelf D": 3,
		"Shelf D2": 2,
		"Shelf D3": 1,
		"Shelf D4": 4
	}

	for shelf_name in shelf_mapping.keys():
		var node = scene.get_node_or_null(shelf_name)
		if node:
			node.set_script(raf_script)
			node.set("parlayan_raf_no", shelf_mapping[shelf_name])

	var pinpad = scene.get_node_or_null("SM_Pin_Pad")
	if pinpad:
		pinpad.set_script(keypad_script)
		pinpad.set("dogru_sifre", "3214")
		pinpad.set("tv_node_yolu", "^../TV2") 

	var new_packed = PackedScene.new()
	new_packed.pack(scene)
	ResourceSaver.save(new_packed, "res://kale.tscn")
	
	print("SUCCESS_DONE")
	quit()
