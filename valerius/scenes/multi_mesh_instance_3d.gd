extends MultiMeshInstance3D

func _ready():
	randomize() 
	
	for i in range(multimesh.instance_count):
		var pos = Vector3(randf_range(-50, 50), -0.075, randf_range(-50, 50))
		
		var basis = Basis(Vector3.UP, randf_range(0, TAU))
		var xform = Transform3D(basis, pos)
		
		
		multimesh.set_instance_transform(i, xform)
