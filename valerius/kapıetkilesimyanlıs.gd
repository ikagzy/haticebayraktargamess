extends StaticBody3D

@export var uyari_label: Label 
@export var mesaj: String = "Bu oda benim değil."

var oyuncu_kapida = false

func _ready():
	# 1. Label Kontrolü
	if uyari_label:
		print("✅ Label başarıyla bağlandı!")
		uyari_label.visible = false
	else:
		print("❌ HATA: Label kutusu BOŞ! Inspector'dan bağlamamışsın.")

	# 2. Area3D Kontrolü
	var area = $Area3D
	if area:
		if not area.body_entered.is_connected(_on_body_entered):
			area.body_entered.connect(_on_body_entered)
		if not area.body_exited.is_connected(_on_body_exited):
			area.body_exited.connect(_on_body_exited)
	else:
		print("❌ HATA: Bu kapının altında 'Area3D' isimli bir düğüm yok!")

func _on_body_entered(body):
	# 3. Oyuncu Algılama Kontrolü
	if body.is_in_group("player"):
		oyuncu_kapida = true
		print("✅ Oyuncu kapı alanına GİRDİ.")
	else:
		print("⚠️ Bir şey kapıya girdi ama 'player' grubunda değil: ", body.name)

func _on_body_exited(body):
	if body.is_in_group("player"):
		oyuncu_kapida = false
		print("✅ Oyuncu kapı alanından ÇIKTI.")
		if uyari_label:
			uyari_label.visible = false

func _unhandled_input(event):
	# 4. Tuş Kontrolü
	if event.is_action_pressed("interact"):
		print("⌨️ E tuşuna basıldı. Oyuncu kapıda mı?: ", oyuncu_kapida)
		
		if oyuncu_kapida:
			mesaj_goster()

func mesaj_goster():
	print("📢 Mesaj ekrana veriliyor...")
	if uyari_label:
		uyari_label.text = mesaj
		uyari_label.visible = true
		
		# Mesaj 2 saniye sonra geri gitsin (Senin istediğin satır burası)
		await get_tree().create_timer(2.0).timeout
		uyari_label.visible = false
