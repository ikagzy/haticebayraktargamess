extends Area3D

var karakter_yakinda = false
var yuzuk_alindi_mi = false
var donmus_oyuncu = null
var kriz_geciriyor = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta):
	if kriz_geciriyor and is_instance_valid(donmus_oyuncu):
		var kamera = donmus_oyuncu.get_node_or_null("head/Camera3D")
		if not kamera:
			kamera = donmus_oyuncu.find_child("Camera3D", true, false)
		if kamera:
			kamera.h_offset = randf_range(-0.06, 0.06)
			kamera.v_offset = randf_range(-0.06, 0.06)
			kamera.rotation_degrees.z = randf_range(-2.0, 2.0)

func _input(event):
	if karakter_yakinda and not yuzuk_alindi_mi and event is InputEventKey and event.pressed and event.keycode == KEY_E:
		yuzugu_al_ve_isinlan()

func yuzugu_al_ve_isinlan():
	if yuzuk_alindi_mi:
		return
	yuzuk_alindi_mi = true
	GlobalAyarlar.yuzuk_alindi = true
	
	visible = false
	
	var oyuncular = get_tree().get_nodes_in_group("Player")
	if oyuncular.size() > 0:
		donmus_oyuncu = oyuncular[0]

	
	if is_instance_valid(donmus_oyuncu):
		donmus_oyuncu.set_physics_process(false)
		donmus_oyuncu.set_process_unhandled_input(false)
		kriz_geciriyor = true
	
	if is_instance_valid(GorevArayuzu) and GorevArayuzu.has_method("altyazi_goster"):
		GorevArayuzu.altyazi_goster("Karakter: Yine mi...", 3.0)
	else:
		print("Karakter: Yine mi...")
		
	var canvas = CanvasLayer.new()
	canvas.layer = 98
	get_tree().current_scene.add_child(canvas)
	var cr = ColorRect.new()
	cr.set_anchors_preset(Control.PRESET_FULL_RECT)
	cr.color = Color(0.4, 0.0, 0.0, 0.0)
	cr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(cr)
	
	var renk_tween = create_tween().set_loops()
	renk_tween.tween_property(cr, "color:a", 0.4, 0.3).set_trans(Tween.TRANS_SINE)
	renk_tween.tween_property(cr, "color:a", 0.05, 0.4).set_trans(Tween.TRANS_SINE)
	renk_tween.tween_property(cr, "color:a", 0.3, 0.2).set_trans(Tween.TRANS_EXPO)
	renk_tween.tween_property(cr, "color:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	
	await get_tree().create_timer(3.0).timeout
	
	kriz_geciriyor = false
	if renk_tween and renk_tween.is_valid():
		renk_tween.kill()
		
	var siyah_ekran = create_tween()
	siyah_ekran.tween_property(cr, "color", Color(0,0,0,1), 0.5)
	await siyah_ekran.finished
	
	if is_instance_valid(donmus_oyuncu):
		donmus_oyuncu.set_physics_process(true)
		donmus_oyuncu.set_process_unhandled_input(true)
		
	get_tree().change_scene_to_file("res://kale_ilk_arsahne.tscn")

func _on_body_entered(body):
	if (body.name == "Player" or body.name == "CharacterBody3D") and not yuzuk_alindi_mi:
		karakter_yakinda = true

func _on_body_exited(body):
	if body.name == "Player" or body.name == "CharacterBody3D":
		karakter_yakinda = false
