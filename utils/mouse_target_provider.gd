class_name MouseTargetProvider
extends TargetProvider

@export var camera : Camera3D

func _ready() -> void:
	assert(camera is Camera3D, "MouseTargetProvider node must have a camera assigned.")


func mouse_to_ground_position():
	var mouse_position = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_normal = camera.project_ray_normal(mouse_position)
	
	# Avoid division by zero if ray is parallel to plane
	if abs(ray_normal.y) < 0.0001:
		return null

	var ray_distance_to_ground = (0 - ray_origin.y) / ray_normal.y
	# Intersection is behind the camera
	if ray_distance_to_ground < 0:
		return null

	return ray_origin + ray_normal * ray_distance_to_ground


func get_target_position() -> Vector3:
	return mouse_to_ground_position()
