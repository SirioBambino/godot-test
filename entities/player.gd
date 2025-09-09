class_name Player
extends Entity

var input_vector : Vector2
var target_direction : Vector3

var camera : Camera3D
var previous_yaw : float = 0.0

func get_stats() -> PlayerStats:
	return stats as PlayerStats

func _ready():
	super()
	camera = get_viewport().get_camera_3d()

func _physics_process(delta):
	input_vector = Input.get_vector("walk_left", "walk_right", "walk_forward", "walk_backward")
	var camera_y_rot = Basis(Vector3.UP, camera.rotation.y)
	get_stats().movement_direction = (camera_y_rot * Utils.Vector2_to_Vector3(input_vector)).normalized()
