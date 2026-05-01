@tool
class_name PrimitiveNode
extends TerrainFeatureNode

const TerrainFeatureNode = "res://addons/terrainy/nodes/terrain_feature_node.gd"


@export var height: float = 10.0:
	set(value):
		height = value
		_commit_parameter_change()
