extends Node

var active_gorev_arayuzu = null
var baslangic_repligi_calindi = false
var oyun_basladi_mi = false
var yalan_soyledi = false
var son2_oynandi = false
var fenere_sahip_mi = false
var isik_acik_mi = false
var odaya_giris_izni = false
var kutuphaneden_geldi = false
var kutuphane_menusu_tetiklendi = false
var ormana_gecis_tamamlandi = false

var vazgecti = false
var kapi_acildi = false
var anahtar_alindi = false
var ruyada_mi = false
var yuzuk_sahip = false
var cubuk_sahip = false
var bicak_sahip = false
var harita_bulundu = false
var kapi_deneme_sayisi = 0
var aktif_hikaye_adimi = "baslangic"
var merdiven_bulundu = false
var kitap_yerlestirildi = false
var kabus_gordu = false

var arayuz_yasakli = false 

func gorev_yazisini_kapat():
	arayuz_yasakli = true
	if is_instance_valid(GorevArayuzu):
		GorevArayuzu.visible = false
		if GorevArayuzu.has_method("_on_gorev_guncellendi"):
			GorevArayuzu._on_gorev_guncellendi("")
func hafizayi_sifirla():
	active_gorev_arayuzu = null
	baslangic_repligi_calindi = false
	oyun_basladi_mi = true
	yalan_soyledi = false
	son2_oynandi = false
	fenere_sahip_mi = false
	isik_acik_mi = false
	odaya_giris_izni = false
	kutuphaneden_geldi = false
	kutuphane_menusu_tetiklendi = false
	ormana_gecis_tamamlandi = false
	arayuz_yasakli = false

	vazgecti = false
	kapi_acildi = false
	anahtar_alindi = false
	ruyada_mi = false
	yuzuk_sahip = false
	cubuk_sahip = false
	bicak_sahip = false
	harita_bulundu = false
	kapi_deneme_sayisi = 0
	aktif_hikaye_adimi = "baslangic"
	merdiven_bulundu = false
	kitap_yerlestirildi = false
	kabus_gordu = false
	
	if is_instance_valid(get_node_or_null("/root/GorevArayuzu")):
		GorevArayuzu.visible = true
