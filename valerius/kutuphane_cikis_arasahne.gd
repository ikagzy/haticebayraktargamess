extends Node3D

@export_group("Kriz Ayarları")
@export var kriz_suresi: float = 4.0
@export var sarsinti_siddeti: float = 1.5

@export_group("Renk (Kan) Ayarları")
@export var kan_rengi: Color = Color(0.4, 0.0, 0.0)
@export var max_saydamlik: float = 0.4
@export var min_saydamlik: float = 0.05

@export_group("Kriz Sonu Geçiş")
@export var kararma_hizi: float = 2.0
@export var son_renk: Color = Color(0, 0, 0)

func _ready() -> void:
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("karakter_cikis_animasyon")
	
	var kamera = find_child("Camera*3D", true, false)
	if not kamera:
		kamera = get_viewport().get_camera_3d()

	var color_rect = find_child("ColorRect", true, false)
	
	_travma_gecir(kamera, color_rect)

func _travma_gecir(kam: Camera3D, cr: ColorRect) -> void:
	if cr:
		cr.color = Color(kan_rengi.r, kan_rengi.g, kan_rengi.b, 0.0) 
		var renk_tween = create_tween().set_loops()
		
		renk_tween.tween_property(cr, "color:a", max_saydamlik, 0.3).set_trans(Tween.TRANS_SINE)
		renk_tween.tween_property(cr, "color:a", min_saydamlik, 0.4).set_trans(Tween.TRANS_SINE)
		renk_tween.tween_property(cr, "color:a", max_saydamlik * 0.8, 0.2).set_trans(Tween.TRANS_EXPO)
		renk_tween.tween_property(cr, "color:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
		
		get_tree().create_timer(kriz_suresi).timeout.connect(func():
			if renk_tween.is_valid(): renk_tween.kill()
			
			var bitis_tween = create_tween()
			bitis_tween.tween_property(cr, "color", Color(son_renk.r, son_renk.g, son_renk.b, 1.0), kararma_hizi) 
		)

	if kam:
		var original_rot_z = kam.rotation.z
		var shake_tween = create_tween().set_loops(kriz_suresi * 4)
		
		shake_tween.tween_property(kam, "rotation:z", 
			original_rot_z + deg_to_rad(randf_range(sarsinti_siddeti/1.5, sarsinti_siddeti)), 0.1)\
			.set_trans(Tween.TRANS_SINE)
		
		shake_tween.tween_property(kam, "rotation:z", 
			original_rot_z - deg_to_rad(randf_range(sarsinti_siddeti/1.5, sarsinti_siddeti)), 0.1)\
			.set_trans(Tween.TRANS_SINE)

		await get_tree().create_timer(kriz_suresi).timeout
		if shake_tween.is_valid(): 
			shake_tween.kill()
		
		var duz_tween = create_tween()
		duz_tween.tween_property(kam, "rotation:z", original_rot_z, 0.5)\
			.set_trans(Tween.TRANS_ELASTIC)

	if is_instance_valid(GorevArayuzu) and GorevArayuzu.has_method("altyazi_goster"):
		GorevArayuzu.altyazi_goster("BAŞIM ÇATLIYOR", 3.0)

	var toplam_bekleme = kriz_suresi + kararma_hizi + 0.5
	await get_tree().create_timer(toplam_bekleme).timeout
	if is_instance_valid(get_node_or_null("/root/SahneGecisi")):
		SahneGecisi.gecis_yap("res://oda.tscn")
	else:
		get_tree().change_scene_to_file("res://oda.tscn")
