extends Node


var son1_acildi = false
var son2_acildi = false
var son3_acildi = false
var son4_acildi = false
var gizli_son1 = false
var gizli_son2 = false
var gizli_son3 = false
var ana_son_acildi = false

var kayit_yolu = "user://basarimlar.save"

func _ready():
	yukle()

func sonu_ac(son_numarasi: int):
	match son_numarasi:
		1: son1_acildi = true
		2: son2_acildi = true
		3: son3_acildi = true
		4: son4_acildi = true
		5: gizli_son1 = true
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
