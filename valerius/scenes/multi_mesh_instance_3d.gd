extends MultiMeshInstance3D

func _ready():
	# Rastgelelik için her seferinde farklı sonuç verir
	randomize() 
	
	for i in range(multimesh.instance_count):
		# KONUM: X ve Z (genişlik) değerlerini ormanının büyüklüğüne göre ayarla
		# Y değerini senin bulduğun -0.075 yapıyoruz
		var pos = Vector3(randf_range(-50, 50), -0.075, randf_range(-50, 50))
		
		# YÖN: Ağaçlar klon gibi durmasın diye rastgele döndürelim
		var basis = Basis(Vector3.UP, randf_range(0, TAU))
		var xform = Transform3D(basis, pos)
		
		# BOYUT: İstersen ağaçları biraz büyütebilirsin
		# xform = xform.scaled(Vector3(1.5, 1.5, 1.5))
		
		multimesh.set_instance_transform(i, xform)
