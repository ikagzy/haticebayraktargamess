extends OmniLight3D

# Ayarları editörden değiştirebilmen için dışarı açıyoruz
@export var min_enerji = 0.0   # Işık en az ne kadar kısılsın? (0 = zifiri karanlık)
@export var maks_enerji = 2.0  # Işık en fazla ne kadar parlasın?
@export var titreme_hizi = 0.05 # Ne sıklıkla değişsin? (Düşük = Çok hızlı titrer)

var zaman_sayaci = 0.0

func _process(delta):
	zaman_sayaci += delta
	
	# Belirlenen süre geçtiyse ışığı değiştir
	if zaman_sayaci > titreme_hizi:
		# Rastgele bir parlaklık seç
		light_energy = randf_range(min_enerji, maks_enerji)
		
		# Sayacı sıfırla
		zaman_sayaci = 0.0
		
		# Hızı da biraz rastgele yap ki makine gibi durmasın (Kaotik olsun)
		titreme_hizi = randf_range(0.02, 0.15)
