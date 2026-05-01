extends Area3D

# anahtar_sonu_tetigi.gd
# Kütüphane çıkış tetikleyicisi — SADECE ANA SON için.
# Kitap okunmadan (kapi_acildi = false) monitoring kapalı kalır.

var tetiklendi = false
var aktif_mi = false

func _ready():
	monitoring = false
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _process(_delta):
	# Sadece kütüphaneden anahtar ALINDIKTAN sonra aktifleşir (çıkışa gidince tetiklenmesi için)
	if not aktif_mi and OyunVerisi.get("anahtar_alindi") == true:
		monitoring = true
		aktif_mi = true
		set_process(false)

func _on_body_entered(body: Node3D):
	if tetiklendi:
		return
	if not (body is CharacterBody3D or body.is_in_group("Player")):
		return
	tetiklendi = true
	set_deferred("monitoring", false)
	cikis_sekansini_baslat(body)

func cikis_sekansini_baslat(oyuncu: Node3D):
	# Oyuncuyu kilitle
	if is_instance_valid(oyuncu):
		oyuncu.set_physics_process(false)
		oyuncu.set_process_unhandled_input(false)

	# İç ses — ara sahnede de kendi efekti var zaten
	if is_instance_valid(GorevArayuzu) and GorevArayuzu.has_method("altyazi_goster"):
		GorevArayuzu.altyazi_goster("Ne gördüm ben... Bu mümkün olamaz.", 3.5)

	# BEKLEMEDEN DİREKT ARA SAHNEYE (Animasyon/Duraksama yok)

	# Ara sahneye geç
	if is_instance_valid(get_node_or_null("/root/SahneGecisi")):
		# NOT: cutscene için direkt geçiş daha iyi olabilir ama SahneGecisi kullanmak istenirse:
		SahneGecisi.gecis_yap("res://kutuphane_cikis_arasahne.tscn")
	else:
		get_tree().change_scene_to_file("res://kutuphane_cikis_arasahne.tscn")
