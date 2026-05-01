extends ColorRect

# Shader'daki 'effect_amount' parametresini kontrol edecek değişken
# 0.0 -> Kapalı, 0.1 -> Çok bozuk
var target_effect_amount : float = 0.0

# Efektin ne kadar hızlı açılıp kapanacağını kontrol eder
var transition_speed : float = 5.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Oyun başladığında efektin tamamen kapalı olduğundan emin olalım
	material.set_shader_parameter("effect_amount", 0.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Mevcut shader parametresini al
	var current_amount = material.get_shader_parameter("effect_amount")
	
	# 'current_amount' değerini, 'target_effect_amount' değerine doğru yavaşça değiştir
	# Bu sayede efekt aniden değil, pürüzsüz bir şekilde ekrana girer
	var new_amount = lerp(current_amount, target_effect_amount, transition_speed * delta)
	
	# Yeni değeri shader'a anlık olarak geri gönder
	material.set_shader_parameter("effect_amount", new_amount)


# Zaman kırılmasını (efekti) başlatmak için başka bir scriptten bu fonksiyonu çağır
func activate_time_rift() -> void:
	target_effect_amount = 0.05 # Hafif kırılma. Daha sert bir etki istersen 0.1 yapabilirsin.


# Zaman kırılmasını durdurmak/kapatmak için bu fonksiyonu çağır
func deactivate_time_rift() -> void:
	target_effect_amount = 0.0
