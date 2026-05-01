extends CanvasLayer

@onready var gorev_label = $Label # Buradaki ismin sahnendekiyle aynı olduğuna emin ol!

func _ready():
	# Sahne başladığında OyunVerisi'ne bu arayüzü kaydet ki her yerden ulaşalım
	OyunVerisi.active_gorev_arayuzu = self

# Bu fonksiyonu dışarıdan çağırıp yazıyı tamamen yok edeceğiz
func arayuzu_kapat():
	self.visible = false
	if gorev_label:
		gorev_label.text = ""

func _on_gorev_guncellendi(yeni_metin: String):
	if yeni_metin == "":
		self.visible = false
	else:
		self.visible = true
		if gorev_label:
			gorev_label.text = yeni_metin	
