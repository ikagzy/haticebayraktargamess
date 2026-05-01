extends Node

# GlobalSonlar.gd - Tüm sonların kaydı ve yüklenmesi
# Not: 4 Ana Son ve 3 Gizli Son bu sistem üzerinden takip edilir.

var son1_acildi = false # SON #1: Vazgeçiş
var son2_acildi = false # SON #2: Travma/Korku
var son3_acildi = false # SON #3: Reddediş/Boşluk
var son4_acildi = false # SON #4: Ganimetsiz/Yalnız
var gizli_son1 = false # GİZLİ SON #1: Platformda Mahsur
var gizli_son2 = false # GİZLİ SON #2: Her şey bir yalan mı?
var gizli_son3 = false # GİZLİ SON #3: Güzel atıştı
var ana_son_acildi = false # ANA SON: Büyünün Uyanışı

var kayit_yolu = "user://basarimlar.save"

func _ready():
	yukle()

# Yeni bir son açıldığında (Son 1, 2, 3, 4 veya Gizli 1, 2, 3)
func sonu_ac(son_numarasi: int):
	match son_numarasi:
		1: son1_acildi = true
		2: son2_acildi = true
		3: son3_acildi = true
		4: son4_acildi = true
		5: gizli_son1 = true # 5. yuva gizli son 1 için
		6: gizli_son2 = true
		7: gizli_son3 = true
		8: ana_son_acildi = true
	
	kaydet()

func kaydet():
	var dosya = FileAccess.open(kayit_yolu, FileAccess.WRITE)
	if dosya:
		var kayit_verisi = {
			"son1": son1_acildi,
			"son2": son2_acildi,
			"son3": son3_acildi,
			"son4": son4_acildi,
			"gizli_son1": gizli_son1,
			"gizli_son2": gizli_son2,
			"gizli_son3": gizli_son3,
			"ana_son": ana_son_acildi
		}
		dosya.store_var(kayit_verisi)
		dosya.close()

func yukle():
	if FileAccess.file_exists(kayit_yolu):
		var dosya = FileAccess.open(kayit_yolu, FileAccess.READ)
		if dosya:
			var kayit_verisi = dosya.get_var()
			if kayit_verisi != null:
				son1_acildi = kayit_verisi.get("son1", false)
				son2_acildi = kayit_verisi.get("son2", false)
				son3_acildi = kayit_verisi.get("son3", false)
				son4_acildi = kayit_verisi.get("son4", false)
				gizli_son1 = kayit_verisi.get("gizli_son1", false)
				gizli_son2 = kayit_verisi.get("gizli_son2", false)
				gizli_son3 = kayit_verisi.get("gizli_son3", false)
				ana_son_acildi = kayit_verisi.get("ana_son", false)
			dosya.close()
