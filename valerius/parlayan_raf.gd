extends Node3D


@export var parlayan_raf_no: int = 1
@export var parlama_rengi: Color = Color(0.3, 0.8, 1.0)
@export var parlama_gucu: float = 2.0
@export var parlama_menzili: float = 1.5

var _isik: OmniLight3D = null
var _obje: CSGSphere3D = null

func _ready():
	randomize()
	parlayan_raf_no = (randi() % 4) + 1
	
	var raf_yukseklikleri = {
		1: 3.5,
		2: 1.5,
		3: -0.5,
		4: -2.5
	}
	
	var hedef_y = raf_yukseklikleri.get(parlayan_raf_no, 1.5)
	var obje_pozisyon = Vector3(0, hedef_y, 0)
	
	_obje = CSGSphere3D.new()
	_obje.radius = 0.2
	_obje.position = obje_pozisyon
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = parlama_rengi
	mat.emission_enabled = true
	mat.emission = parlama_rengi
	mat.emission_energy_multiplier = 3.0
	_obje.material_override = mat
	add_child(_obje)
	
	_isik = OmniLight3D.new()
	_isik.name = "RafIsigi"
	_isik.light_color = parlama_rengi
	_isik.light_energy = parlama_gucu
	_isik.omni_range = parlama_menzili
	_isik.shadow_enabled = false
	_isik.position = obje_pozisyon
	add_child(_isik)
	
	_titreme_baslat()

func _titreme_baslat():
	var tween = create_tween().set_loops()
	
	tween.tween_property(_isik, "light_energy", parlama_gucu * 1.3, 1.2).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(mat_getir(), "emission_energy_multiplier", 6.0, 1.2).set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(_isik, "light_energy", parlama_gucu * 0.7, 1.2).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(mat_getir(), "emission_energy_multiplier", 2.0, 1.2).set_trans(Tween.TRANS_SINE)

func mat_getir() -> StandardMaterial3D:
	return _obje.material_override as StandardMaterial3D
