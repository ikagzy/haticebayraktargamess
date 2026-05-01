extends Node3D

func _ready():
	await get_tree().create_timer(0.5).timeout
	_muzik_degistir()

func _muzik_degistir():
	for node in get_tree().get_nodes_in_group("arka_plan_sesi"):
		if node is AudioStreamPlayer:
			var t = create_tween()
			t.tween_property(node, "volume_db", -80.0, 2.0)
			await t.finished
			node.stop()

	for node in get_tree().root.get_children():
		if node is AudioStreamPlayer and node.playing:
			var s = node.stream
			if s and "universfield" in str(s.resource_path):
				var t = create_tween()
				t.tween_property(node, "volume_db", -80.0, 2.0)
				await t.finished
				node.stop()

	var kale_muzigi = AudioStreamPlayer.new()
	var ses = load("res://oyununarkaplansesi_2.mp3")
	if ses:
		ses.loop = true
		kale_muzigi.stream = ses
		kale_muzigi.volume_db = -12.0
		kale_muzigi.autoplay = false
		add_child(kale_muzigi)
		kale_muzigi.play()
