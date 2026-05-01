extends Area3D

# yatak_tetigi.gd — SADECE ANA SON yolu.
# NPC'ler oda.gd _ready()'de zaten gizlendi.
# Burası sadece: kilitle → karar → kale.tscn

@export var uyuma_suresi: float = 3.0
@export var hedef_sahne: String = "res://uyku_arasahne.tscn"

var tetiklendi = false

func _ready():
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if tetiklendi:
		return
	if not (body is CharacterBody3D or body.is_in_group("Player")):
		return
	# Kütüphaneye gidilmemişse pasif
	if not OyunVerisi.get("kapi_acildi"):
		return
	if OyunVerisi.get("ruyada_mi"):
		return

	tetiklendi = true
	set_deferred("monitoring", false)
	uyuma_sekansini_baslat(body)

func uyuma_sekansini_baslat(oyuncu: Node3D):
	# 1. OYUNCUYU KİLİTLE
	if is_instance_valid(oyuncu):
		oyuncu.set_physics_process(false)
		oyuncu.set_process_unhandled_input(false)

	# 2. ALTYAZI
	if is_instance_valid(GorevArayuzu) and GorevArayuzu.has_method("altyazi_goster"):
		GorevArayuzu.altyazi_goster("Gözlerim kapanıyor... Uyuyorum.", uyuma_suresi)

	# 3. KARARMA
	var canvas = CanvasLayer.new()
	canvas.layer = 99
	get_tree().current_scene.add_child(canvas)
	var kararti = ColorRect.new()
	kararti.color = Color(0, 0, 0, 0)
	kararti.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(kararti)

	var tween = create_tween()
	tween.tween_interval(uyuma_suresi * 0.7)
	tween.tween_property(kararti, "color:a", 1.0, 1.2)
	await tween.finished

	# 4. ANA SON — Kale sahnesine geç
	if is_instance_valid(get_node_or_null("/root/SahneGecisi")):
		SahneGecisi.gecis_yap(hedef_sahne)
	else:
		get_tree().change_scene_to_file(hedef_sahne)
