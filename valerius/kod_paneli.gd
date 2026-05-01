extends Node

# Kale Kütüphanesi Kod Paneli ve Final Mantığı
# Şifre: 251367486

var deneme_sayisi = 0

func kod_girisi(girilen_kod: String):
	if girilen_kod == "251367486":
		if OyunVerisi.yuzuk_sahip:
			gercek_sonu_baslat()
		else:
			gizli_son_iki_tetikle()
	else:
		if is_instance_valid(GorevArayuzu):
			GorevArayuzu.altyazi_goster("Kod yanlış görünüyor...", 2.0)

func gizli_son_iki_tetikle():
	if is_instance_valid(GorevArayuzu):
		GorevArayuzu.altyazi_goster("İşlem başarılı... Ama birden yer sallanmaya başladı!", 3.0)
	
	await get_tree().create_timer(3.0).timeout
	GlobalSonlar.sonu_ac(6) # 6. slot gizli_son2 için ayrılmıştı
	siyah_ekran_ve_son_yazisi("İnceleme #1: Gizli Son #2 - Her şey bir yalan mıydı?\nKütüphanede bayıldığını düşünüyor. Bütün o büyü...")

func gercek_sonu_baslat():
	if is_instance_valid(GorevArayuzu):
		GorevArayuzu.altyazi_goster("Yüzüğüm parlıyor! Birisi geliyor... Connor?!", 4.0)
		
	await get_tree().create_timer(4.5).timeout
	if is_instance_valid(GorevArayuzu):
		GorevArayuzu.altyazi_goster("Connor: 'Lanetimi serbest bıraktın Marcus... Teşekkürler. Sana bir mesaj bıraktım.'", 5.0)
		
	await get_tree().create_timer(5.0).timeout
	OyunVerisi.aktif_hikaye_adimi = "final_gunesli"
	GlobalSonlar.sonu_ac(8) # Ana Son
	siyah_ekran_ve_son_yazisi("ANA SON: Büyünün Uyanışı\nMarcus odasında uyanır. Her şey eskisi gibidir, ancak çantasındaki yüzük duruyordur.")

func siyah_ekran_ve_son_yazisi(bitis_metni: String):
	var canvas = CanvasLayer.new()
	canvas.layer = 100 
	add_child(canvas)

	var siyah_arkaplan = ColorRect.new()
	siyah_arkaplan.color = Color(0, 0, 0, 0) 
	siyah_arkaplan.set_anchors_preset(Control.PRESET_FULL_RECT) 
	canvas.add_child(siyah_arkaplan)

	var yazi = Label.new()
	yazi.text = bitis_metni
	yazi.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	yazi.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	yazi.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var ayarlar = LabelSettings.new()
	ayarlar.font_size = 48
	ayarlar.outline_size = 4
	ayarlar.outline_color = Color(0, 0, 0, 1)
	var mont = load("res://Montserrat-VariableFont_wght.ttf")
	if mont:
		ayarlar.font = mont
	yazi.label_settings = ayarlar
	yazi.modulate.a = 0 
	canvas.add_child(yazi)

	var tween = create_tween()
	tween.tween_property(siyah_arkaplan, "color:a", 1.0, 2.5)
	tween.tween_property(yazi, "modulate:a", 1.0, 1.5)
	tween.tween_interval(5.0)
	tween.tween_property(yazi, "modulate:a", 0.0, 1.5)
	
	await tween.finished
	ana_menuye_don()

func ana_menuye_don():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if is_instance_valid(OyunVerisi):
		OyunVerisi.arayuz_yasakli = true 
		if OyunVerisi.has_method("gorev_yazisini_kapat"):
			OyunVerisi.gorev_yazisini_kapat()
	get_tree().change_scene_to_file("res://main_menu.tscn")
