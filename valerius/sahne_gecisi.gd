extends CanvasLayer

@onready var siyah_ekran = $ColorRect

func _ready():
	# Oyun başlarken siyah ekranı görünmez (şeffaf) yapıyoruz
	siyah_ekran.show()
	siyah_ekran.modulate.a = 0.0 

func gecis_yap(yeni_sahne_yolu: String):
	# 1. KARARMA: Tween oluştur ve 1.5 saniyede ekranı simsiyah yap
	var tween_karar = get_tree().create_tween()
	tween_karar.tween_property(siyah_ekran, "modulate:a", 1.0, 1.5)
	
	# Kararmanın bitmesini bekle
	await tween_karar.finished
	
	# Zifiri karanlıkta 0.5 saniye bekle (Gerilim hissi için)
	await get_tree().create_timer(0.5).timeout
	
	# 2. SAHNEYİ DEĞİŞTİR
	get_tree().change_scene_to_file(yeni_sahne_yolu)
	
	# 3. AYDINLANMA: Yeni Tween oluştur ve 1.5 saniyede ekranı şeffaf yap
	var tween_aydinlan = get_tree().create_tween()
	tween_aydinlan.tween_property(siyah_ekran, "modulate:a", 0.0, 1.5)
