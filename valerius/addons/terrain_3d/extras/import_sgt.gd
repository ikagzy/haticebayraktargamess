
@tool
extends Terrain3D

@export var simple_grass_textured: MultiMeshInstance3D
@export var assign_mesh_id: int
@export var import: bool = false : set = import_sgt
@export var clear_instances: bool = false : set = clear_multimeshes


func clear_multimeshes(value: bool) -> void:
	get_instancer().clear_by_mesh(assign_mesh_id)


func import_sgt(value: bool) -> void:
	var sgt_mm: MultiMesh = simple_grass_textured.multimesh
	var global_xform: Transform3D = simple_grass_textured.global_transform	
	print("Starting to import %d instances from SimpleGrassTextured using mesh id %d" % [ sgt_mm.instance_count, assign_mesh_id])
	var time: int = Time.get_ticks_msec()
	get_instancer().add_multimesh(assign_mesh_id, sgt_mm, simple_grass_textured.global_transform)	
	print("Import complete in %.2f seconds" % [ float(Time.get_ticks_msec() - time)/1000. ])
	
