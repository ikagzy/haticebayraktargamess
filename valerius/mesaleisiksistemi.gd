extends Light3D # OmniLight3D veya SpotLight3D üzerinde çalışır.

# --- GELİŞMİŞ MEŞALE IŞIK SİSTEMİ (PRO) ---
# Bu script, gürültü (Noise) tabanlı doğal titremeyi, rastgele "parlama" efektlerini
# ve gerçekçi renk değişimlerini bir araya getirir.

@export_group("Temel Titreme Ayarları")
@export var etkin: bool = true                        # Sistemi aç/kapat
@export var en_dusuk_titreme_gucu: float = 0.8        # Orijinal enerjinin min çarpanı
@export var en_yuksek_titreme_gucu: float = 1.2       # Orijinal enerjinin max çarpanı
@export var titreme_hizi: float = 3.0                 # Titreme hızı (3.0 = Daha yavaş ve sakin)

@export_group("Anlık Parlama & Çıtırtı")
@export var anlik_parlama_etkin: bool = true          # Ara sıra anlık parlama olsun mu?
@export var parlama_sansi: float = 0.01               # Her frame'de parlama olma şansı (0.01 = %1)
@export var parlama_gucu: float = 1.6                 # Parlama anındaki enerji çarpanı

@export_group("Menzil Dinamiği")
@export var menzil_titremesi: bool = true             # Işık menzili titresin mi?

@export_group("Pozisyon Sarsıntısı")
@export var pozisyon_sarsintisi: bool = true          # Alev hareketi simülasyonu
@export var sarsinti_miktari: float = 0.05            # Ne kadar sağa sola kayabilir?

# Dahili Değişkenler
var orijinal_enerji: float
var orijinal_menzil: float
var orijinal_pozisyon: Vector3
var zaman: float = 0.0
var noise = FastNoiseLite.new()

func _ready():
	# Başlangıç değerlerini güvenli bir şekilde kaydet
	orijinal_enerji = light_energy
	orijinal_pozisyon = position
	
	if get_class() == "OmniLight3D":
		orijinal_menzil = get("omni_range")
	elif get_class() == "SpotLight3D":
		orijinal_menzil = get("spot_range")
	
	# Gürültü (Noise) ayarlarını yap
	randomize()
	noise.seed = randi()
	noise.frequency = 0.5 # Yumuşak geçişler için

func _process(delta):
	if not etkin:
		return
		
	zaman += delta * titreme_hizi
	
	# 1. TEMEL TİTREME (Noise Tabanlı)
	var n_val = (noise.get_noise_1d(zaman) + 1.0) / 2.0 # 0 ile 1 arası değer
	var hedef_enerji_orani = lerp(en_dusuk_titreme_gucu, en_yuksek_titreme_gucu, n_val)
	
	# 2. ANLIK PARLAMA (Eğer şans yaver giderse)
	if anlik_parlama_etkin and randf() < parlama_sansi:
		hedef_enerji_orani = parlama_gucu
	
	# Enerjiyi uygula
	light_energy = orijinal_enerji * hedef_enerji_orani
	
	# 3. MENZİL TİTREMESİ
	if menzil_titremesi:
		var m_val = (noise.get_noise_1d(zaman + 500) + 1.0) / 2.0
		var menzil_orani = lerp(0.9, 1.1, m_val)
		if get_class() == "OmniLight3D":
			set("omni_range", orijinal_menzil * menzil_orani)
		elif get_class() == "SpotLight3D":
			set("spot_range", orijinal_menzil * menzil_orani)
			
	# 5. POZİSYON SARSINTISI (Alev gibi dalgalanma)
	if pozisyon_sarsintisi:
		var off_x = noise.get_noise_1d(zaman + 1000) * sarsinti_miktari
		var off_y = noise.get_noise_1d(zaman + 2000) * sarsinti_miktari
		var off_z = noise.get_noise_1d(zaman + 3000) * sarsinti_miktari
		position = orijinal_pozisyon + Vector3(off_x, off_y, off_z)
