extends SpotLight3D

@export var takip_edilecek_hedef: Node3D
@export var smooth_hizi: float = 12.0
@export var titreme_miktari: float = 0.015
@export var titreme_hizi: float = 3.0

func _ready():
	if takip_edilecek_hedef:
		set_as_top_level(true)

func _process(delta):
	if takip_edilecek_hedef == null:
		return

	global_position = takip_edilecek_hedef.global_position

	var zaman = Time.get_ticks_msec() * 0.001 * titreme_hizi
	var shake_x = sin(zaman * 1.1) * titreme_miktari
	var shake_y = cos(zaman * 1.3) * titreme_miktari
	var shake_z = sin(zaman * 0.7) * (titreme_miktari * 0.5)

	var hedef_aci = takip_edilecek_hedef.global_transform.basis
	
	hedef_aci = hedef_aci.rotated(hedef_aci.x, shake_x)
	hedef_aci = hedef_aci.rotated(hedef_aci.y, shake_y)
	hedef_aci = hedef_aci.rotated(hedef_aci.z, shake_z)

	global_transform.basis = global_transform.basis.slerp(hedef_aci, delta * smooth_hizi)
