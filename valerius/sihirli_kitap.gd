extends Node

@export var kitap_yazisi: String = "... Bu yazilar da ne? MIDEM BULANIYOR..."
@export var yazi_suresi: float = 5.0
@export var kriz_suresi: float = 6.0

var kitap_kullanildi_mi = false
var donmus_oyuncu = null
var kriz_geciriyor = false

func _process(_delta):
	if kriz_geciriyor and is_instance_valid(donmus_oyuncu):
		var kamera = donmus_oyuncu.get_node_or_null("head/Camera3D")
		if not kamera:
			kamera = donmus_oyuncu.find_child("Camera3D", true, false)
		if kamera:
			kamera.h_offset = randf_range(-0.06, 0.06)
			kamera.v_offset = randf_range(-0.06, 0.06)
			kamera.rotation_degrees.z = randf_range(-2.0, 2.0)

func kitap_etkilesimi(oyuncu):
	if kitap_kullanildi_mi:
		return
	kitap_kullanildi_mi = true
	donmus_oyuncu = oyuncu

	if get_parent() and get_parent().is_in_group("SihirliKitap"):
		get_parent().remove_from_group("SihirliKitap")

	if is_instance_valid(oyuncu):
		oyuncu.set_physics_process(false)
		oyuncu.set_process_unhandled_input(false)
		kriz_geciriyor = true

	if is_instance_valid(oyuncu):
		var yazi = oyuncu.get_node_or_null("CanvasLayer/Label")
		if yazi:
			yazi.hide()

	if is_instance_valid(GorevArayuzu) and GorevArayuzu.has_method("altyazi_goster"):
		GorevArayuzu.altyazi_goster(kitap_yazisi, yazi_suresi)
		GorevArayuzu._on_gorev_guncellendi("Görev: Kütüphaneden Çık")

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

	var kamera = oyuncu.get_node_or_null("head/Camera3D")
	if not kamera:
		kamera = oyuncu.find_child("Camera3D", true, false)

	var shake_tween = null
	var original_rot_z = 0.0

	if kamera:
		original_rot_z = kamera.rotation.z
		shake_tween = create_tween()
		shake_tween.set_loops(0)
		shake_tween.tween_property(kamera, "rotation:z",
			original_rot_z + deg_to_rad(randf_range(3.5, 6.0)), 0.06)\
			.set_trans(Tween.TRANS_SINE)
		shake_tween.tween_property(kamera, "rotation:z",
			original_rot_z - deg_to_rad(randf_range(3.5, 6.0)), 0.06)\
			.set_trans(Tween.TRANS_SINE)

	await get_tree().create_timer(kriz_suresi).timeout

	kriz_geciriyor = false
	if shake_tween:
		shake_tween.kill()
		
	if renk_tween and renk_tween.is_valid():
		renk_tween.kill()
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(cr, "color:a", 0.0, 1.0)
	fade_out_tween.tween_callback(canvas.queue_free)
	if kamera:
		var duz_tween = create_tween()
		duz_tween.tween_property(kamera, "rotation:z", original_rot_z, 0.5)\
			.set_trans(Tween.TRANS_ELASTIC)
		kamera.h_offset = 0.0
		kamera.v_offset = 0.0
		kamera.rotation_degrees.z = rad_to_deg(original_rot_z)

	if is_instance_valid(donmus_oyuncu):
		donmus_oyuncu.set_physics_process(true)
		donmus_oyuncu.set_process_unhandled_input(true)
		if donmus_oyuncu.has_method("kalici_travma_baslat"):
			donmus_oyuncu.kalici_travma_baslat()
	var kilitli_kapi = get_tree().get_first_node_in_group("Girilmez")
	if kilitli_kapi:
		kilitli_kapi.remove_from_group("Girilmez")
		kilitli_kapi.add_to_group("Kapi")

	if is_instance_valid(OyunVerisi):
		OyunVerisi.kapi_acildi = true

	if is_instance_valid(GorevArayuzu) and GorevArayuzu.has_method("altyazi_goster"):
		GorevArayuzu.altyazi_goster("Kapi acildi! Hemen cikmam gerekiyor...", 3.0)
