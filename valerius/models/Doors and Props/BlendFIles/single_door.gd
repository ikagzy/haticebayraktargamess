extends Node3D 

@onready var anim_player = $AnimationPlayer2
var acik_mi = false

# Oyuncu E'ye basınca lazer bu fonksiyonu tetikleyecek
func etkilesime_gir():
	# EĞER ŞU AN BİR ANİMASYON OYNUYORSA İŞLEMİ İPTAL ET (BEKLEME SÜRESİ/DELAY)
	if anim_player.is_playing():
		return
		
	if acik_mi:
		anim_player.play("kapi_kapali") # <-- Buraya kendi kapanma animasyonunun adını yaz
		acik_mi = false
	else:
		anim_player.play("kapı_acik")  # <-- Buraya kendi açılma animasyonunun adını yaz
		acik_mi = true
