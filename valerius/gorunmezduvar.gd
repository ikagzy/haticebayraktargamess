extends Area3D

@export var uyari_metni: String = "BURASI KARANLIK DURUYOR GİDEMEM"
@export var yazi_suresi: float = 3.0
@export var sadece_bir_kere_goster: bool = false

var yazi_ekranda: bool = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if yazi_ekranda: return
	
	if body.name == "Player" or body.is_in_group("Player"):
		_uyari_ver()

func _uyari_ver():
	yazi_ekranda = true
	
	if is_instance_valid(GorevArayuzu):
		if GorevArayuzu.has_method("altyazi_goster"):
			GorevArayuzu.altyazi_goster(uyari_metni, yazi_suresi)
			print("Altyazı gösterildi: ", uyari_metni)
	
	if sadece_bir_kere_goster:
		set_deferred("monitoring", false)
	else:
		await get_tree().create_timer(yazi_suresi + 1.0).timeout
		yazi_ekranda = false
