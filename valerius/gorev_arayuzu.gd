extends CanvasLayer

@onready var label = $Label
@onready var bilgi_kutusu = $BilgiKutusu

@onready var tab_menusu = $TabMenusu
@onready var gorev_metni = $TabMenusu/GorevMetni
@onready var altyazi_kutusu = $AltyaziKutusu
@onready var altyazi_metni = $AltyaziKutusu/AltyaziMetni

var ilk_gorev = "Görev: Masanın Üstünden El Fenerini Al"
var aktif_gorev = ""

func _ready():
	label.text = ""
	label.visible_characters = 0
	label.modulate.a = 0.0
	
	if bilgi_kutusu:
		bilgi_kutusu.position.x = get_viewport().get_visible_rect().size.x + 50
		
	if tab_menusu:
		tab_menusu.visible = false
	if altyazi_kutusu:
		altyazi_kutusu.modulate.a = 0.0
		altyazi_kutusu.visible = false

func _process(_delta):
	var current_scene = get_tree().current_scene
	if current_scene:
		var sahne_yolu = current_scene.scene_file_path
		
		if "main_menu.tscn" in sahne_yolu or "okulcutscene.tscn" in sahne_yolu or "res://odacutscene.tscn" in sahne_yolu:
			self.visible = false
			OyunVerisi.oyun_basladi_mi = false
			
		else:
			self.visible = true
			
			if not OyunVerisi.oyun_basladi_mi:
				OyunVerisi.oyun_basladi_mi = true
				_ilk_gorevi_havali_baslat()

func _input(event):
	if event is InputEventKey and event.keycode == KEY_TAB:
		if event.pressed:
			tab_menusu.visible = true
		else:
			tab_menusu.visible = false

func _ilk_gorevi_havali_baslat():
	await get_tree().create_timer(0.5).timeout
	
	var o_anki_gorev = ilk_gorev
	var current_scene = get_tree().current_scene
	
	if current_scene:
		var sahne_ismi = current_scene.name.to_lower()
		var sahne_yolu = current_scene.scene_file_path.to_lower()
		
		if "okul" in sahne_ismi or "okul" in sahne_yolu:
			o_anki_gorev = "Görev: Okulu Araştır"
			
		elif "kale" in sahne_ismi or "kale" in sahne_yolu:
			o_anki_gorev = "Görev: Kaleyi Araştır"
			
		
	_on_gorev_guncellendi(o_anki_gorev)
	
	if tab_menusu and tab_menusu is ColorRect:
		tab_menusu.color = Color(0, 0, 0, 0.4)
	

func _on_gorev_guncellendi(yeni_yazi):
	aktif_gorev = yeni_yazi
	
	if gorev_metni:
		var temiz_yazi = yeni_yazi.replace("Görev: ", "").replace("Gorev: ", "")
		
		gorev_metni.text = "Görev: " + temiz_yazi 
		gorev_metni.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		gorev_metni.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		gorev_metni.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		gorev_metni.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		
	if not self.visible:
		label.text = yeni_yazi
		label.visible_characters = -1 
		return

	if label.text == yeni_yazi: 
		return

	animasyon_baslat(yeni_yazi)

func animasyon_baslat(yeni_yazi):
	var tween = create_tween()
	
	label.modulate.a = 1.0 
	
	var suanki_uzunluk = label.text.length()
	
	if suanki_uzunluk > 0:
		var silme_suresi = suanki_uzunluk * 0.015 
		tween.tween_method(gorsel_guncelle, suanki_uzunluk, 0, silme_suresi)
		tween.tween_interval(0.05) 
	
	tween.tween_callback(func():
		label.text = yeni_yazi
		label.visible_characters = 0 
		cizgi_konumunu_guncelle(0)   
	)
	
	if suanki_uzunluk == 0:
		tween.tween_interval(0.05) 
	
	var yeni_uzunluk = yeni_yazi.length()
	var yazma_suresi = yeni_uzunluk * 0.02
	tween.tween_method(gorsel_guncelle, 0, yeni_uzunluk, yazma_suresi)
	
	tween.tween_interval(3.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.5)

func gorsel_guncelle(karakter_sayisi: int):
	label.visible_characters = karakter_sayisi
	cizgi_konumunu_guncelle(karakter_sayisi)

func cizgi_konumunu_guncelle(_karakter_sayisi: int):
	pass

func ekrana_bilgi_bas(yeni_bilgi: String):
	if not bilgi_kutusu: return
	
	var kutu_yazisi = bilgi_kutusu.get_node("Label")
	if kutu_yazisi:
		kutu_yazisi.text = yeni_bilgi
	
	bilgi_kutusu.reset_size()
	
	var ekran_genisligi = get_viewport().get_visible_rect().size.x
	var ekran_yuksekligi = get_viewport().get_visible_rect().size.y
	var kutu_genisligi = bilgi_kutusu.size.x
	var kutu_yuksekligi = bilgi_kutusu.size.y
	
	bilgi_kutusu.position.y = (ekran_yuksekligi / 2.0) - (kutu_yuksekligi / 2.0)
	
	var hedef_x = ekran_genisligi - kutu_genisligi - 20 
	
	var tween = create_tween()
	
	tween.tween_property(bilgi_kutusu, "position:x", hedef_x, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(4.5)
	tween.tween_property(bilgi_kutusu, "position:x", ekran_genisligi + 50, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func altyazi_goster(yazi: String, sure: float = 3.0):
	if not altyazi_kutusu or not altyazi_metni: return
	
	altyazi_metni.text = yazi
	altyazi_kutusu.visible = true
	
	var tween = create_tween()
	tween.tween_property(altyazi_kutusu, "modulate:a", 1.0, 0.5)
	
	tween.tween_interval(sure)
	
	tween.tween_property(altyazi_kutusu, "modulate:a", 0.0, 0.5)
	
	tween.tween_callback(func(): altyazi_kutusu.visible = false)
