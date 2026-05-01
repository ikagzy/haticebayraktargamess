extends CanvasLayer

# SAHNE AĞACINDAKİ İSİMLERİ KONTROL ET!
# Sol üstteki yazı VBoxContainer içindeyse onu, ortadaki panel başka yerdeyse onu seçiyoruz.
@onready var sol_ust_gorev = $Control/VBoxContainer # Sol üstteki yazı grubu
@onready var orta_tab_paneli = $Control/GorevPaneli # Tab'a basınca açılan orta kısım (İsmi neyse onu yaz)
@onready var icerik_yazisi = $Control/VBoxContainer/IcerikLabel

func _ready():
	# Başlangıçta görevi yazdır (Autoload ismin globaltasks ise)
	if has_node("/root/globaltasks"):
		icerik_yazisi.text = GorevArayuzu.current_task_text

func _input(event):
	# EĞER SON SAHNEDEYSEK TAB TUŞUNA BASILMASINI ENGELLE
	if OyunVerisi.arayuz_yasakli:
		if event.is_action_pressed("tab"): # Proje Ayarlarındaki Tab ismi neyse o
			get_viewport().set_input_as_handled() # Tuşu iptal et
			return

func _process(_delta):
	# === NÜKLEER TEMİZLİK BÖLGESİ ===
	# Eğer yasaklıysak veya menüdeysek sadece GÖREV elemanlarını gizle
	if OyunVerisi.arayuz_yasakli or get_tree().current_scene.name == "MainMenu":
		if sol_ust_gorev: sol_ust_gorev.visible = false
		if orta_tab_paneli: orta_tab_paneli.visible = false
		# 'self.visible' demediğimiz için 'Geri Dön' butonu (eğer dışarıdaysa) silinmez!
	else:
		# Oyun içindeysek her şey normal çalışsın
		if sol_ust_gorev: sol_ust_gorev.visible = true
