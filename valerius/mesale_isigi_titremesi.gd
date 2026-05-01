extends OmniLight3D

# İstersen bu değerleri Godot'ta sağdaki (Inspector) menüsünden değiştirebilirsin!
@export var en_dusuk_titreme_gucu: float = 0.8 # Orijinal enerjinin %80'ine kadar düşer
@export var en_yuksek_titreme_gucu: float = 1.1 # Orijinal enerjinin %110'una kadar çıkar
@export var titreme_hizi_min: float = 0.05 # Geçiş hızı (en hızlısı)
@export var titreme_hizi_max: float = 0.15 # Geçiş hızı (en yavaşı)

var orijinal_enerji: float = 1.0

func _ready():
	# Oyun başladığında kendi ışık gücünü (hedef enerji) kaydet
	orijinal_enerji = light_energy
	
	# Titreme döngüsünü direkt başlat
	_mesale_titreme_dongusu()

func _mesale_titreme_dongusu():
	# Belirlediğimiz sınırlar arasında rastgele bir şiddet hesapla
	var rastgele_enerji = orijinal_enerji * randf_range(en_dusuk_titreme_gucu, en_yuksek_titreme_gucu)
	
	# O şiddete ne kadar sürede geçeceğini belirle
	var rastgele_sure = randf_range(titreme_hizi_min, titreme_hizi_max)
	
	# self (Bu OmniLight3D düğümü) için gücü ayarla
	var tween = create_tween()
	tween.tween_property(self , "light_energy", rastgele_enerji, rastgele_sure)
	
	# Titreme bitince tekrar kendini baştan başlat!
	tween.finished.connect(_mesale_titreme_dongusu)
