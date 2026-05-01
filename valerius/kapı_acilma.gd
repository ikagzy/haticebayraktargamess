extends AnimatableBody3D

@onready var anim_player = $"../AnimationPlayer2"

@export_group("Kütüphane Kapısı")
# Inspector'dan işaretle → E'ye basınca ara sahne oynar
@export var kutuphane_kapisi: bool = false
@export var giris_altyazisi: String = "Kütüphaneye gireceğim... En fazla ne olabilir?"
@export var altyazi_suresi: float = 2.5
@export var arasahne_bekleme_suresi: float = 1.0   # Altyazıdan sonra kaç sn beklensin

var kapi_acik_mi = false
var hareket_ediyor_mu = false

# Lazerinin (RayCast) kapıya bakıp E'ye bastığında çağırdığı fonksiyon
func etkilesime_gir():
	# 1. KORUMA: Eğer kapı o an zaten açılıyor veya kapanıyorsa, hiçbir şey yapma!
	if hareket_ediyor_mu == true:
		return

	# === KÜTÜPHANE KAPISI ÖZEL MANTIĞI ===
	if kutuphane_kapisi:
		# Daha önce girilmediyse ara sahneyi oynat (sadece 1. giriş!)
		if not OyunVerisi.kapi_acildi:
			hareket_ediyor_mu = true
			OyunVerisi.kapi_acildi = true

			if is_instance_valid(GorevArayuzu) and GorevArayuzu.has_method("altyazi_goster"):
				GorevArayuzu.altyazi_goster(giris_altyazisi, altyazi_suresi)

			# Altyazıyı okuyacak kadar bekle, sonra ara sahne
			await get_tree().create_timer(arasahne_bekleme_suresi).timeout
			get_tree().change_scene_to_file("res://kutuphane_ara_sahne.tscn")
			return
		# Zaten girilmişse normal kapı gibi davran (aşağıya devam)


	# Kapı hareket etmeye başladı, kalkanı indir (Başka tıklamaları engelle)
	hareket_ediyor_mu = true 
	
	# 2. AÇMA / KAPAMA MANTIĞI
	if kapi_acik_mi == false:
		anim_player.play("kapı_acik") # Animasyon panelindeki adla BİREBİR aynı olmalı
		kapi_acik_mi = true
	else:
		anim_player.play("kapi_kapali") # Animasyon panelindeki adla BİREBİR aynı olmalı
		kapi_acik_mi = false
		
	# 3. MÜKEMMEL DELAY (Animasyonun bitmesini bekle)
	await anim_player.animation_finished 
	
	# Animasyon bitti, kalkanı kaldır, artık tekrar E'ye basılabilir.
	hareket_ediyor_mu = false


# ================= YENİ: KAPIYI ZORLA KAPAT VE KİLİTLE (TUZAK) =================
func zorla_kapat_ve_kitle():
	# Kapı kilitlendikten sonra oyuncuyu korkutmak/bekletmek için 2 saniye delay.
	# (Bunu alt bir kronometreye bağladık ki kapının "kapanma"ca işlemini bloklayıp dondurmasın)
	get_tree().create_timer(2.0).timeout.connect(func():
		if is_instance_valid(GorevArayuzu):
			GorevArayuzu._on_gorev_guncellendi("Görev: Kütüphaneyi Araştır")
	)
	
	# Eğer kapı bir şekilde zaten kapalıysa sadece kilitleme işlemini yapsın
	if kapi_acik_mi == true:
		# Oyuncu normal yolla E'ye basıp araya girmesin diye kalkanı aç
		hareket_ediyor_mu = true 
		
		# Kapıyı zorla kapat!
		anim_player.play("kapi_kapali") 
		kapi_acik_mi = false
		
	# EN ÖNEMLİ KISIM: Kapının grubunu (kimliğini) değiştiriyoruz!
	# Artık "Kapi" grubunda olmadığı için oyuncunun lazeri bunu açılabilir bir kapı olarak GÖRMEYECEK.
	if self.is_in_group("Kapi"):
		self.remove_from_group("Kapi")
		
	self.add_to_group("Girilmez") # Lazerin "Şu an giremezsin." yazısını çıkaracağı gruba soktuk
	
	# Kapanma animasyonu bitene kadar bekle, sonra kalkanı indir
	# (Gerçi gruptan çıktığı için istese de E'ye basamayacak ama kodumuz temiz kalsın)
	await anim_player.animation_finished
	hareket_ediyor_mu = false
