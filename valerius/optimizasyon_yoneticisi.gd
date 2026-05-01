extends Node



@export var uzak_silinme_mesafesi: float = 40.0
@export var sis_baslangic: float = 25.0
@export var sis_bitis: float = 45.0
@export var sis_rengi: Color = Color(0, 0, 0, 1)

var _kamera: Camera3D = null
var _kontrol_suresi: float = 0.0

func _ready():
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node):
	if node is Camera3D:
		await get_tree().process_frame
		_kamera = node

func _process(delta: float):
	_kontrol_suresi += delta
	if _kontrol_suresi < 2.0:
		return
	_kontrol_suresi = 0.0
	
	if not is_instance_valid(_kamera):
		_kamera = _kamerayı_bul()

func _kamerayı_bul() -> Camera3D:
	var kameras = get_tree().get_nodes_in_group("Camera3D")
	if kameras.size() > 0:
		return kameras[0]
	for n in get_tree().get_nodes_in_group("player"):
		var cam = n.find_child("Camera3D", true, false)
		if cam:
			return cam
	return null
