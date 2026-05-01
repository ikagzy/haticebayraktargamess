extends SpotLight3D

# ==================== AYARLAR ====================
@export var takip_edilecek_hedef: Node3D # Kamerayı veya fenerin durması gereken yeri buraya atacağız
@export var smooth_hizi: float = 12.0    # Fenerin dönme hızı (Düşürdükçe daha hantal/ağır olur)
@export var titreme_miktari: float = 0.015 # El titremesi şiddeti
@export var titreme_hizi: float = 3.0    # Titreme hızı

func _ready():
	# Feneri bağlı olduğu objeden (babadan) bağımsız hale getiriyoruz. 
	# Yoksa smooth (gecikmeli) dönüş yapamaz, takoz gibi kameraya yapışır.
	if takip_edilecek_hedef:
		set_as_top_level(true)

func _process(delta):
	# Eğer takip edilecek bir şey seçmediysen kod hata vermesin diye durduruyoruz
	if takip_edilecek_hedef == null:
		return

	# 1. POZİSYON: Fenerin konumunu anında hedefin (kameranın) konumuna eşitliyoruz
	global_position = takip_edilecek_hedef.global_position

	# 2. TİTREME (Hand-Shake) MATEMATİĞİ
	var zaman = Time.get_ticks_msec() * 0.001 * titreme_hizi
	var shake_x = sin(zaman * 1.1) * titreme_miktari
	var shake_y = cos(zaman * 1.3) * titreme_miktari
	var shake_z = sin(zaman * 0.7) * (titreme_miktari * 0.5)

	# Hedefin (Kameranın) o anki açısını alıyoruz
	var hedef_aci = takip_edilecek_hedef.global_transform.basis
	
	# Hedef açının üstüne bizim titreme değerlerini ekliyoruz
	hedef_aci = hedef_aci.rotated(hedef_aci.x, shake_x)
	hedef_aci = hedef_aci.rotated(hedef_aci.y, shake_y)
	hedef_aci = hedef_aci.rotated(hedef_aci.z, shake_z)

	# 3. YUMUŞAK DÖNÜŞ (SMOOTH/LERP)
	# Fenerin şu anki açısından, hesapladığımız titremeli hedef açıya doğru yumuşakça dön
	global_transform.basis = global_transform.basis.slerp(hedef_aci, delta * smooth_hizi)
