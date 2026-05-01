extends Light3D


@export_group("Temel Titreme Ayarları")
@export var etkin: bool = true
@export var en_dusuk_titreme_gucu: float = 0.8
@export var en_yuksek_titreme_gucu: float = 1.2
@export var titreme_hizi: float = 3.0

@export_group("Anlık Parlama & Çıtırtı")
@export var anlik_parlama_etkin: bool = true
@export var parlama_sansi: float = 0.01
@export var parlama_gucu: float = 1.6

@export_group("Menzil Dinamiği")
@export var menzil_titremesi: bool = true

@export_group("Pozisyon Sarsıntısı")
@export var pozisyon_sarsintisi: bool = true
@export var sarsinti_miktari: float = 0.05

var orijinal_enerji: float
var orijinal_menzil: float
var orijinal_pozisyon: Vector3
var zaman: float = 0.0
var noise = FastNoiseLite.new()

func _ready():
	orijinal_enerji = light_energy
	orijinal_pozisyon = position
	
	if get_class() == "OmniLight3D":
		orijinal_menzil = get("omni_range")
	elif get_class() == "SpotLight3D":
		orijinal_menzil = get("spot_range")
	
	randomize()
	noise.seed = randi()
	noise.frequency = 0.5

func _process(delta):
	if not etkin:
		return
		
	zaman += delta * titreme_hizi
	
	var n_val = (noise.get_noise_1d(zaman) + 1.0) / 2.0
	var hedef_enerji_orani = lerp(en_dusuk_titreme_gucu, en_yuksek_titreme_gucu, n_val)
	
	if anlik_parlama_etkin and randf() < parlama_sansi:
		hedef_enerji_orani = parlama_gucu
	
	light_energy = orijinal_enerji * hedef_enerji_orani
	
	if menzil_titremesi:
		var m_val = (noise.get_noise_1d(zaman + 500) + 1.0) / 2.0
		var menzil_orani = lerp(0.9, 1.1, m_val)
		if get_class() == "OmniLight3D":
			set("omni_range", orijinal_menzil * menzil_orani)
		elif get_class() == "SpotLight3D":
			set("spot_range", orijinal_menzil * menzil_orani)
			
	if pozisyon_sarsintisi:
		var off_x = noise.get_noise_1d(zaman + 1000) * sarsinti_miktari
		var off_y = noise.get_noise_1d(zaman + 2000) * sarsinti_miktari
		var off_z = noise.get_noise_1d(zaman + 3000) * sarsinti_miktari
		position = orijinal_pozisyon + Vector3(off_x, off_y, off_z)
