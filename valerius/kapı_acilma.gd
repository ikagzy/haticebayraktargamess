extends AnimatableBody3D

@onready var anim_player = $"../AnimationPlayer2"

@export_group("Kütüphane Kapısı")
@export var kutuphane_kapisi: bool = false
@export var giris_altyazisi: String = "Kütüphaneye gireceğim... En fazla ne olabilir?"
@export var altyazi_suresi: float = 2.5
@export var arasahne_bekleme_suresi: float = 1.0

var kapi_acik_mi = false
var hareket_ediyor_mu = false

func etkilesime_gir():
	if hareket_ediyor_mu == true:
		return

	if kutuphane_kapisi:
		if not OyunVerisi.kapi_acildi:
			hareket_ediyor_mu = true
			OyunVerisi.kapi_acildi = true

			if is_instance_valid(GorevArayuzu) and GorevArayuzu.has_method("altyazi_goster"):
				GorevArayuzu.altyazi_goster(giris_altyazisi, altyazi_suresi)

			await get_tree().create_timer(arasahne_bekleme_suresi).timeout
			get_tree().change_scene_to_file("res://kutuphane_ara_sahne.tscn")
			return


	hareket_ediyor_mu = true 
	
	if kapi_acik_mi == false:
		anim_player.play("kapı_acik")
		kapi_acik_mi = true
	else:
		anim_player.play("kapi_kapali")
		kapi_acik_mi = false
		
	await anim_player.animation_finished 
	
	hareket_ediyor_mu = false


func zorla_kapat_ve_kitle():
	get_tree().create_timer(2.0).timeout.connect(func():
		if is_instance_valid(GorevArayuzu):
			GorevArayuzu._on_gorev_guncellendi("Görev: Kütüphaneyi Araştır")
	)
	
	if kapi_acik_mi == true:
		hareket_ediyor_mu = true 
		
		anim_player.play("kapi_kapali") 
		kapi_acik_mi = false
		
	if self.is_in_group("Kapi"):
		self.remove_from_group("Kapi")
		
	self.add_to_group("Girilmez")
	
	await anim_player.animation_finished
	hareket_ediyor_mu = false
