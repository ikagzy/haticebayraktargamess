extends StaticBody3D

# --- DEĞİŞİKLİK 1: Varsayılan olarak node_3d.tscn yaptık ---
# Artık Inspector'dan seçmesen bile otomatik oraya gidecek.
@export_file("*.tscn") var hedef_sahne_yolu: String = "res://node_3d.tscn"

@onready var interaction_area = $Area3D
# Senin sahne ağacındaki CanvasGroup/Label yoluna göre ayarlandı
@onready var mesaj_label = $CanvasGroup/Label 

var player_in_area = false

func _ready():
	# Sinyalleri koda bağlıyoruz (Editörden bağlamana gerek kalmaz)
	if interaction_area:
		if not interaction_area.body_entered.is_connected(_on_body_entered):
			interaction_area.body_entered.connect(_on_body_entered)
		if not interaction_area.body_exited.is_connected(_on_body_exited):
			interaction_area.body_exited.connect(_on_body_exited)
	
	# Oyun başında yazıyı kapat
	if mesaj_label:
		mesaj_label.visible = false

func _on_body_entered(body):
	# Karakterin "player" grubundaysa çalışır
	if body.is_in_group("player"):
		player_in_area = true
		if mesaj_label:
			mesaj_label.text = "Girmek için [E] tuşuna bas"
			mesaj_label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		if mesaj_label:
			mesaj_label.visible = false

func _unhandled_input(event):
	# E tuşuna basıldığında ve oyuncu kapıdayken çalışır
	if player_in_area and event.is_action_pressed("interact"):
		
		# --- DEĞİŞİKLİK 2: Görev Güncelleme ---
		# Kapıdan geçerken görevi "Okulu keşfet" yapıyoruz.
		if GorevArayuzu:
			GorevArayuzu.gorevi_degistir("Okulu keşfet")
		
		# --- DEĞİŞİKLİK 3: Sahne Değişimi ---
		if hedef_sahne_yolu != "":
			print("Gidilen yol: ", hedef_sahne_yolu)
			get_tree().change_scene_to_file(hedef_sahne_yolu)
		else:
			print("Hata: Hedef sahne yolu boş!")
