extends Panel

@onready var label_isim = $LabelIsim 
@onready var label_mesaj = $LabelMesaj

func setup(isim: String, mesaj: String):
	label_isim.text = isim
	label_mesaj.text = mesaj
	
	if "GİZLİ" in isim or "Gizli" in isim:
		self.self_modulate = Color("9b59b6")
	else:
		self.self_modulate = Color("3498db")
