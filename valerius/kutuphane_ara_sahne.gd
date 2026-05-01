extends Node3D


@export_group("Animasyon")
@export var animasyon_adi: String = "kapiittirme"

@export_group("Altyazılar (Sırayla oynar)")
@export var altyazilar: Array[String] = [
	"Kütüphaneye girdim... Burası çok sessiz.",
]
@export var altyazi_suresi: float = 3.0

@export_group("Görev Güncelleme")
@export var gorevi_guncelle: bool = true
@export var yeni_gorev: String = "Görev: Kütüphaneyi araştır"

@onready var animasyon_oynatici = get_node_or_null("AnimationPlayer")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	var kararti = ColorRect.new()
	kararti.color = Color(0, 0, 0, 1)
	kararti.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(kararti)
	add_child(canvas)
	
	var tween = create_tween()
	tween.tween_property(kararti, "color:a", 0.0, 1.2)
	tween.finished.connect(func(): canvas.queue_free())
	
	if animasyon_oynatici and animasyon_oynatici.has_animation(animasyon_adi):
		var anim = animasyon_oynatici.get_animation(animasyon_adi)
		if anim:
			anim.loop_mode = Animation.LOOP_NONE
		animasyon_oynatici.play(animasyon_adi)
		await animasyon_oynatici.animation_finished
	else:
		await get_tree().create_timer(2.0).timeout

	if is_instance_valid(GorevArayuzu):
		for i in altyazilar.size():
			GorevArayuzu.altyazi_goster(altyazilar[i], altyazi_suresi)
			if i < altyazilar.size() - 1:
				await get_tree().create_timer(altyazi_suresi + 0.2).timeout

		if gorevi_guncelle and yeni_gorev != "":
			GorevArayuzu._on_gorev_guncellendi(yeni_gorev)

	ana_sahneye_don()

func ana_sahneye_don():
	OyunVerisi.kutuphaneden_geldi = true
	OyunVerisi.kapi_acildi = true
	get_tree().change_scene_to_file("res://node_3d.tscn")
