extends Area3D

# =====================================================
# ALTYAZI TETİKLEYİCİ - Inspector'dan tamamen ayarlanabilir
# Bu scripti herhangi bir Area3D'ye bağla.
# Oyuncu alana girince sırayla tüm altyazıları gösterir.
# =====================================================

@export_group("Altyazılar")
@export var altyazilar: Array[String] = ["Burası garip hissettiriyor..."]
@export var altyazi_suresi: float = 3.0  # Her altyazının kaç saniye kalacağı

@export_group("Görev Güncelleme")
@export var gorevi_guncelle: bool = false
@export var yeni_gorev_metni: String = ""

@export_group("OyunVerisi Bayrağı")
@export var bayrak_adi: String = ""          # Örn: "yalan_soyledi", "kapi_acildi"
@export var bayrak_degeri: bool = true       # Hangi değere set edilsin

@export_group("Sahne Geçişi")
@export var sahne_gecisi_yap: bool = false
@export var hedef_sahne: String = ""        # Örn: "res://oda.tscn"
@export var gecis_gecikmesi: float = 1.0

@export_group("Tetikleyici Ayarları")
@export var bir_kez_tetikle: bool = true    # Sadece 1 kez mi?
@export var travma_efekti_ac: bool = false  # TravmaEfekti ColorRect'i tetiklesin mi?

var tetiklendi = false

func _on_body_entered(body: Node3D) -> void:
	if not (body is CharacterBody3D):
		return
	if bir_kez_tetikle and tetiklendi:
		return
	tetiklendi = true
	set_deferred("monitoring", not bir_kez_tetikle)
	_tetikle()

func _tetikle():
	# --- TRAVMA EFEKTİ ---
	if travma_efekti_ac:
		var travma = get_tree().root.find_child("TravmaEfekti", true, false)
		if travma and travma.has_method("efekt_baslat"):
			travma.efekt_baslat()

	# --- OYUNVERİSİ BAYRAK ---
	if bayrak_adi != "" and OyunVerisi.get(bayrak_adi) != null:
		OyunVerisi.set(bayrak_adi, bayrak_degeri)

	# --- ALTYAZILAR (Sırayla) ---
	if is_instance_valid(GorevArayuzu):
		for i in altyazilar.size():
			GorevArayuzu.altyazi_goster(altyazilar[i], altyazi_suresi)
			if i < altyazilar.size() - 1:
				await get_tree().create_timer(altyazi_suresi + 0.3).timeout

		# --- GÖREV GÜNCELLE ---
		if gorevi_guncelle and yeni_gorev_metni != "":
			GorevArayuzu._on_gorev_guncellendi(yeni_gorev_metni)

	# --- SAHNE GEÇİŞİ ---
	if sahne_gecisi_yap and hedef_sahne != "":
		await get_tree().create_timer(gecis_gecikmesi).timeout
		get_tree().change_scene_to_file(hedef_sahne)
