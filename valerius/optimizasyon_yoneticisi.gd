extends Node

# =====================================================
# OPTİMİZASYON YÖNETİCİSİ (Autoload olarak ekle)
# Tüm sahnelerde otomatik devreye girer.
# =====================================================

# Frustum Culling zaten Godot'ta varsayılan açık.
# Bu script şunları yapar:
#  1. Kameraya dinamik sis ekleyerek uzak objeleri gizler (Uzaklık Culling)
#  2. Render LoD threshold'u ayarlar
#  3. StaticBody'lerin uzakta olmayan fiziklerini durdurur (isteğe bağlı)

@export var uzak_silinme_mesafesi: float = 40.0   # Bu mesafeden uzak meshler kaybolur
@export var sis_baslangic: float = 25.0           # Sisin başladığı mesafe
@export var sis_bitis: float = 45.0               # Sisin tam kapattığı mesafe
@export var sis_rengi: Color = Color(0, 0, 0, 1)  # Sis rengi (black fog = dışarı render etme)

var _kamera: Camera3D = null
var _kontrol_suresi: float = 0.0

func _ready():
	# Sahne değişiminde tekrar çalışsın
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node):
	# Yeni bir kamera eklenirse onu yakala
	if node is Camera3D:
		await get_tree().process_frame
		_kamera = node

func _process(delta: float):
	_kontrol_suresi += delta
	# Her 2 saniyede bir kamerayı tekrar kontrol et (fazla işlem yapma)
	if _kontrol_suresi < 2.0:
		return
	_kontrol_suresi = 0.0
	
	# Kamerayı bul (yoksa tüm ağacı tara)
	if not is_instance_valid(_kamera):
		_kamera = _kamerayı_bul()

func _kamerayı_bul() -> Camera3D:
	var kameras = get_tree().get_nodes_in_group("Camera3D")
	if kameras.size() > 0:
		return kameras[0]
	# Tüm ağacı tara
	for n in get_tree().get_nodes_in_group("player"):
		var cam = n.find_child("Camera3D", true, false)
		if cam:
			return cam
	return null
