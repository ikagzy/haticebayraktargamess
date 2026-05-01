extends Node3D 

# SÜRELER KISALTILDI (Test için veya hızlı aksiyon için)
@export var min_bekleme: float = 2.0  # En az 2 saniye bekler
@export var max_bekleme: float = 5.0  # En fazla 5 saniye bekler
@export var ekranda_kalma: float = 0.3 # Camda sadece saliselik kalsın (Bilinçaltı korkusu!)

func _ready():
	visible = false 
	randomize() 
	korku_dongusunu_baslat()

func korku_dongusunu_baslat():
	# 1. Aşama: 2 ila 5 saniye arası rastgele pusuya yat
	var bekleme_suresi = randf_range(min_bekleme, max_bekleme)
	await get_tree().create_timer(bekleme_suresi).timeout
	
	# 2. Aşama: Ceeee! 
	visible = true
	
	# 3. Aşama: Sadece 0.3 saniye camda kal
	await get_tree().create_timer(ekranda_kalma).timeout
	
	# 4. Aşama: Kaybol ve başa dön
	visible = false
	korku_dongusunu_baslat()
