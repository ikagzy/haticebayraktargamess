extends Area3D

# İstersen bu kısımları Godot ekranından değiştirebilirsin
@export var uyari_metni: String = "BURASI KARANLIK DURUYOR GİDEMEM"
@export var yazi_suresi: float = 3.0
@export var sadece_bir_kere_goster: bool = false

var yazi_ekranda: bool = false

func _ready():
	# Sinyali koda bağla
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	# Eğer yazı zaten ekrandaysa veya başka bir şey çarptıysa bosver
	if yazi_ekranda: return
	
	# Eğer çarpan kişi oyuncuysa yazıyı göster
	if body.name == "Player" or body.is_in_group("Player"):
		_uyari_ver()

func _uyari_ver():
	# Yazının spamlenmesini engelle
	yazi_ekranda = true
	
	# Oyundaki altyazı sistemine mesajı gönder
	if is_instance_valid(GorevArayuzu):
		if GorevArayuzu.has_method("altyazi_goster"):
			GorevArayuzu.altyazi_goster(uyari_metni, yazi_suresi)
			print("Altyazı gösterildi: ", uyari_metni)
	
	# Eğer "Sadece 1 kere göster" tikini seçtiysen Area3D kendini tamamen kapatır
	if sadece_bir_kere_goster:
		set_deferred("monitoring", false)
	else:
		# Eğer seçmediysen, yazı ekrandan gidene kadar bekle (Süre + 1 saniye) ve sonra tekrar çalışabilir hale gel
		await get_tree().create_timer(yazi_suresi + 1.0).timeout
		yazi_ekranda = false
