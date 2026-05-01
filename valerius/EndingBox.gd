extends Panel

# Sahne içindeki Label isimlerini kontrol et (İsimler farklıysa burayı düzelt)
@onready var label_isim = $LabelIsim 
@onready var label_mesaj = $LabelMesaj

func setup(isim: String, mesaj: String):
	label_isim.text = isim
	label_mesaj.text = mesaj
	
	# Tasarım: Gizli sonları mor, diğerlerini mavi yap
	if "GİZLİ" in isim or "Gizli" in isim:
		self.self_modulate = Color("9b59b6") # Mor
	else:
		self.self_modulate = Color("3498db") # Mavi
