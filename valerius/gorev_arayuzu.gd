extends CanvasLayer

@onready var label = $Label # Sol üstteki daktilo yazısı
@onready var bilgi_kutusu = $BilgiKutusu # Sağdan gelen fener bilgisi

# --- YENİ EKLENEN TAB MENÜSÜ DÜĞÜMLERİ ---
@onready var tab_menusu = $TabMenusu
@onready var gorev_metni = $TabMenusu/GorevMetni
@onready var altyazi_kutusu = $AltyaziKutusu
@onready var altyazi_metni = $AltyaziKutusu/AltyaziMetni

var ilk_gorev = "Görev: Masanın Üstünden El Fenerini Al"
var aktif_gorev = "" # TAB menüsünde sürekli görünecek asıl görev

func _ready():
	label.text = ""
	label.visible_characters = 0
	label.modulate.a = 0.0 # Başlangıçta sol üstteki yazı görünmez olsun
	
	if bilgi_kutusu:
		bilgi_kutusu.position.x = get_viewport().get_visible_rect().size.x + 50
		
	if tab_menusu:
		tab_menusu.visible = false # Oyun başlarken TAB menüsü gizli olsun
	if altyazi_kutusu:
		altyazi_kutusu.modulate.a = 0.0 # Şeffaf yap
		altyazi_kutusu.visible = false

func _process(_delta):
	var current_scene = get_tree().current_scene
	if current_scene:
		var sahne_yolu = current_scene.scene_file_path
		
		# Eğer Ana Menü'deysek VEYA Cutscene'lerdeysek gizle
		if "main_menu.tscn" in sahne_yolu or "okulcutscene.tscn" in sahne_yolu or "res://odacutscene.tscn" in sahne_yolu:
			self.visible = false
			# Ana menüye dönersek hafızayı sıfırlıyoruz ki yeni oyunda tekrar çalsın
			OyunVerisi.oyun_basladi_mi = false
			
		# Odaya (veya Okula) geçersek:
		else:
			self.visible = true
			
			# === İŞTE BURASI: GLOBAL HAFIZA KONTROLÜ ===
			# Eğer oyun verisinde henüz oyun başlamadıysa başlat, hafızaya kaydet.
			# Böylece sahneler arası gidip gelince tekrar çalışmayacak!
			if not OyunVerisi.oyun_basladi_mi:
				OyunVerisi.oyun_basladi_mi = true
				_ilk_gorevi_havali_baslat()

# --- YENİ EKLENEN: TAB TUŞU KONTROLÜ ---
func _input(event):
	if event is InputEventKey and event.keycode == KEY_TAB:
		if event.pressed:
			tab_menusu.visible = true # TAB'a basılıyken göster
		else:
			tab_menusu.visible = false # Çekince gizle

func _ilk_gorevi_havali_baslat():
	await get_tree().create_timer(0.5).timeout
	
	# Hangi sahnede olduğumuzu öğrenmek için sahne sistemini kontrol ediyoruz
	var o_anki_gorev = ilk_gorev
	var current_scene = get_tree().current_scene
	
	if current_scene:
		var sahne_ismi = current_scene.name.to_lower()
		var sahne_yolu = current_scene.scene_file_path.to_lower()
		
		# Eğer test sırasında veya normalde Okul sahnesindeysek:
		if "okul" in sahne_ismi or "okul" in sahne_yolu:
			o_anki_gorev = "Görev: Okulu Araştır"
			
		# Eğer test sırasında Kale sahnesindeysek:
		elif "kale" in sahne_ismi or "kale" in sahne_yolu:
			o_anki_gorev = "Görev: Kaleyi Araştır"
			
		# Zaten Oda'daysak "Masanın üstünden feneri al" (ilk_gorev) kalacak.
		
	_on_gorev_guncellendi(o_anki_gorev)
	
	# Tabmenüsü arkaplan transparan yapıldı
	if tab_menusu and tab_menusu is ColorRect:
		tab_menusu.color = Color(0, 0, 0, 0.4) # Eskiden daha koyuydu, ya da 0 yapabiliriz. Fotoğrafta bir arkaplan var ColorRect tarzında, tam yazının sınırlarına göre sığması isteniyor.
	
	# EĞER SHİFT İLE KOŞMA REPLİĞİNİ BURADAN ÇAĞIRIYORSAN AŞAĞIDAKİ YORUMU KALDIR:
	# altyazi_goster("Shift ile hızlı koşabilirsin...", 4.0)

func _on_gorev_guncellendi(yeni_yazi):
	aktif_gorev = yeni_yazi
	
	# === YENİ EKLENEN: TAB MENÜSÜ YAZI FORMATI ===
	if gorev_metni:
		# Hem "Görev: " hem "Gorev: " eklerini temizle (hata önlemi)
		var temiz_yazi = yeni_yazi.replace("Görev: ", "").replace("Gorev: ", "")
		
		# Direkt yanyana yazdırıyoruz
		gorev_metni.text = "Görev: " + temiz_yazi 
		# Yazının kutunun tam ortasında durması için kodla hizalamayı açıyoruz
		gorev_metni.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		gorev_metni.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		# Kutunun boyutunu değil, YAZIYI kutuya uyduruyoruz:
		# Autowrap (otomatik satır atlama) açılır. Yazı çok uzunsa kutu içinde alt satıra geçer.
		gorev_metni.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		# Yazı kutusunun sınırlarını siyah arka planla (ColorRect) BİREBİR EŞİTLİYORUZ
		gorev_metni.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		
	# (Aşağıdaki daktilo kısımları aynen kalıyor)
	if not self.visible:
		label.text = yeni_yazi
		label.visible_characters = -1 
		return

	if label.text == yeni_yazi: 
		return

	animasyon_baslat(yeni_yazi)

# --- TWEEN (ANİMASYON MOTORU) ---
func animasyon_baslat(yeni_yazi):
	var tween = create_tween()
	
	# Yeni yazı geldiğinde önceden silinmiş olma ihtimaline karşı görünürlüğü (Alpha) tekrar 1 yapıyoruz
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
	
	# ================= YENİ EKLENEN YOK OLMA SİSTEMİ =================
	# Daktilo yazmayı bitirdikten sonra 3 saniye ekranda beklet:
	tween.tween_interval(3.0)
	# Ardından 1.5 saniye içinde yavaşça (fade out) şeffaflaşıp kaybolsun!
	tween.tween_property(label, "modulate:a", 0.0, 1.5)

func gorsel_guncelle(karakter_sayisi: int):
	label.visible_characters = karakter_sayisi
	cizgi_konumunu_guncelle(karakter_sayisi)

func cizgi_konumunu_guncelle(_karakter_sayisi: int):
	# Daktilo imleci (line/cursor) sistemi şu an pasif. 
	# Gelecekte imleç efekti eklenirse burası güncellenebilir.
	pass

# ==================== DİNAMİK BİLGİ/İPUCU SİSTEMİ ====================
func ekrana_bilgi_bas(yeni_bilgi: String):
	if not bilgi_kutusu: return
	
	# Kutunun içindeki yazıyı değiştiriyoruz
	var kutu_yazisi = bilgi_kutusu.get_node("Label")
	if kutu_yazisi:
		kutu_yazisi.text = yeni_bilgi
	
	# ÇOK ÖNEMLİ: Kutuya "İçindeki yazı değişti, yeni boyutunu hesapla!" diyoruz
	bilgi_kutusu.reset_size()
	
	var ekran_genisligi = get_viewport().get_visible_rect().size.x
	var ekran_yuksekligi = get_viewport().get_visible_rect().size.y
	var kutu_genisligi = bilgi_kutusu.size.x
	var kutu_yuksekligi = bilgi_kutusu.size.y
	
	# KUTUYU TAM KIRMIZI ÇİZDİĞİN YERE (Y Ekseninde Ortaya) ALIYORUZ
	bilgi_kutusu.position.y = (ekran_yuksekligi / 2.0) - (kutu_yuksekligi / 2.0)
	
	var hedef_x = ekran_genisligi - kutu_genisligi - 20 
	
	var tween = create_tween()
	
	# Ekrana kayarak gir
	tween.tween_property(bilgi_kutusu, "position:x", hedef_x, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Oyuncu rahatça okusun diye 4.5 saniye ekranda tut
	tween.tween_interval(4.5)
	# Sağdan ekran dışına çıkarak yok ol
	tween.tween_property(bilgi_kutusu, "position:x", ekran_genisligi + 50, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

# ==================== ALTYAZI / SOHBET SİSTEMİ ====================
func altyazi_goster(yazi: String, sure: float = 3.0):
	if not altyazi_kutusu or not altyazi_metni: return
	
	# Yazıyı kutuya basıyoruz
	altyazi_metni.text = yazi
	altyazi_kutusu.visible = true
	
	var tween = create_tween()
	# 1. Yavaşça ekranda belir (Fade In)
	tween.tween_property(altyazi_kutusu, "modulate:a", 1.0, 0.5)
	
	# 2. Oyuncu okusun diye bekle
	tween.tween_interval(sure)
	
	# 3. Yavaşça kaybol (Fade Out)
	tween.tween_property(altyazi_kutusu, "modulate:a", 0.0, 0.5)
	
	# İşlem bitince tamamen gizle ki arkada boşuna çalışmasın
	tween.tween_callback(func(): altyazi_kutusu.visible = false)
