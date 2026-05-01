extends SpotLight3D

# Ayarları buradan veya sağdaki Inspector panelinden değiştirebilirsin
@export var min_enerji: float = 0.2  # Işığın en kısık hali
@export var max_enerji: float = 2.0  # Işığın en parlak hali
@export var titreme_sikligi: float = 0.1  # Titreme hızı

var sayac: float = 0.0

func _process(delta: float) -> void:
	sayac += delta
	
	# Sayaç belirlediğimiz sıklığa ulaşınca ışığı değiştir
	if sayac >= titreme_sikligi:
		sayac = 0.0
		
		# Enerjiyi minimum ve maksimum arasında rastgele ayarla
		light_energy = randf_range(min_enerji, max_enerji)
		
		# KORKU EFEKTİ: %15 ihtimalle ışık anlık olarak tamamen kapansın
		if randf() < 0.15:
			light_energy = 0.0
			
		# Bir sonraki titreme süresini de rastgele yap ki robotik, ezberlenmiş gibi durmasın
		titreme_sikligi = randf_range(0.05, 0.3)
