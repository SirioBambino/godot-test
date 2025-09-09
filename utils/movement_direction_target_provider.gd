class_name MovementDirectionTargetProvider
extends TargetProvider

@export var source_node : NodePath
var last_direction : Vector3 = Vector3.FORWARD

func get_target_position() -> Vector3:
	assert(source_node != null, "MovementDirectionTargetProvider's source must be set.")
	
	var node = get_node(source_node)
	assert(node is Entity, "MovementDirectionTargetProvider's source must be an Entity node.")
	
	
	if node.get_stats().movement_direction and node.get_stats().movement_direction.length_squared() > 0.01:
		last_direction = node.get_stats().movement_direction
	
	return node.global_position + last_direction
