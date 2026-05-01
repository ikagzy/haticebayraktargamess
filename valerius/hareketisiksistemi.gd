extends Area3D

## Hareket Sensörlü Işık ve Meşale Sistemi
## Bu script, üzerinden geçen oyuncuyu algılar ve ışıkları yavaşça açar, ardından titretir.

@export_group("Işık Ayarları")
## Birinci ışık (Genellikle bu Area3D'nin altındaki çocuktur)
@export var isik1: OmniLight3D
## İkinci ışık (Sahnenin başka bir yerindeki ışık, editörden seçilmelidir)
@export var isik2: OmniLight3D

var isik_yandi: bool = false
var hedef_enerji1: float = 1.0
var hedef_enerji2: float = 1.0

func _ready():
	# Eğer isik1 atanmamışsa altındaki çocuk OmniLight3D'yi bulmaya çalış
	if isik1 == null:
		isik1 = get_node_or_null("OmniLight3D")
	
	# Başlangıç enerjilerini kaydet ve ışıkları kapat
	if is_instance_valid(isik1):
		hedef_enerji1 = isik1.light_energy if isik1.light_energy > 0 else 1.0
		isik1.light_energy = 0.0
		isik1.visible = true
	
	if is_instance_valid(isik2):
		hedef_enerji2 = isik2.light_energy if isik2.light_energy > 0 else 1.0
		isik2.light_energy = 0.0
		isik2.visible = true
	
	# Sinyal bağlantısını kontrol ederek yap
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if isik_yandi:
		return
	
	# Oyuncu tespiti: İsim, grup veya CharacterBody3D sınıfı üzerinden kontrol
	var is_player = body.is_in_group("Player") or body.name == "Player" or body is CharacterBody3D
	
	if is_player:
		isik_yandi = true
		
		var tween = create_tween().set_parallel(true)
		
		if is_instance_valid(isik1):
			tween.tween_property(isik1, "light_energy", hedef_enerji1, 2.0)\
				.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_IN_OUT)
		
		if is_instance_valid(isik2):
			tween.tween_property(isik2, "light_energy", hedef_enerji2, 2.0)\
				.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_IN_OUT)
		
		# Tüm başlangıç açılma animasyonu bitince titreşimi başlat
		tween.finished.connect(_titremeye_basla)
		
		print("Işıklar algılandı ve açılıyor...")

func _titremeye_basla():
	_mesale_titreme_dongusu()

func _mesale_titreme_dongusu():
	# Güvenlik: Işıklar sahnede yoksa döngüyü sessizce bitir
	if not is_instance_valid(isik1) and not is_instance_valid(isik2):
		return
		
	var tween = create_tween().set_parallel(true)
	var rastgele_sure = randf_range(0.05, 0.15)
	var is_any_light_active = false
	
	if is_instance_valid(isik1):
		var r_enerji1 = hedef_enerji1 * randf_range(0.8, 1.1)
		tween.tween_property(isik1, "light_energy", r_enerji1, rastgele_sure)
		is_any_light_active = true
	
	if is_instance_valid(isik2):
		var r_enerji2 = hedef_enerji2 * randf_range(0.8, 1.1)
		tween.tween_property(isik2, "light_energy", r_enerji2, rastgele_sure)
		is_any_light_active = true
	
	# Döngü için tekrar bağlan
	if is_any_light_active:
		tween.finished.connect(_mesale_titreme_dongusu)
