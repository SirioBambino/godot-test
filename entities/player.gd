class_name Player
extends Entity

var input_vector : Vector2
var movement_direction : Vector3 = Vector3.ZERO
var target_direction : Vector3

var camera : Camera3D
var previous_yaw : float = 0.0

func get_player_stats() -> PlayerStats:
	return stats as PlayerStats

func _ready():
	super()
	camera = get_viewport().get_camera_3d()

func _physics_process(delta):
	input_vector = Input.get_vector("walk_left", "walk_right", "walk_forward", "walk_backward")
	var camera_y_rot = Basis(Vector3.UP, camera.rotation.y)
	movement_direction = (camera_y_rot * Utils.Vector2_to_Vector3(input_vector)).normalized()
	
	if get_player_stats().always_follow_mouse:
		target_direction = mouse_to_ground_position()
	else:
		if Input.is_action_pressed("aim"):
			target_direction = mouse_to_ground_position()
		else:
			target_direction = global_position + movement_direction
	
	if target_direction != null:
		rotate_towards_target(target_direction)

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


func rotate_towards_target(target : Vector3, smooth_factor : float = 0.1) -> void:
	var origin_position = Utils.Vector3_to_ground(global_position)
	var target_position = Utils.Vector3_to_ground(target)
	var direction = origin_position.direction_to(target_position)

	if direction.length_squared() > 0.001:
		var target_yaw = Utils.get_yaw_from_direction(direction)
		rotation.y = lerp_angle(rotation.y, target_yaw, smooth_factor)
		
		var yaw_diff = Utils.angle_difference(rotation.y, previous_yaw)
		previous_yaw = rotation.y
