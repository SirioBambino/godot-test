class_name LookAtState
extends State

@export var target_provider : TargetProvider
@export var rotation_speed : float = 0.1

var _debug_sphere : MeshInstance3D
var _node : Entity

var debug = false

func init(data := {}) -> void:
	if state_machine:
		_node = state_machine._parent
	assert(_node is Entity, "LookAt state %s can only be used on an Entity node." % _node.name)

func _ready() -> void:
	# Create sphere if it does not exist
	if not _debug_sphere:
		_debug_sphere = MeshInstance3D.new()
		_debug_sphere.mesh = SphereMesh.new()
		_debug_sphere.mesh.radius = 0.25
		_debug_sphere.mesh.height = 0.25

		# Add as a child to the same parent as this state
		if debug:
			self.add_child.call_deferred(_debug_sphere)


func enter(data := {}) -> void:	
	_debug_sphere.show()


func exit() -> void:
	_debug_sphere.hide()


func update(_delta : float) -> void:
	pass


func physics_update(_delta : float) -> void:
	if not target_provider:
		return
	var target_position = target_provider.get_target_position()
	
	# Move the sphere to the target position
	if _debug_sphere and _debug_sphere.is_inside_tree():
		_debug_sphere.global_position = target_position
	
	rotate_towards_target(target_position, rotation_speed)


func rotate_towards_target(target : Vector3, smooth_factor : float) -> void:
	var origin_position = Utils.Vector3_to_ground(_node.global_position)
	var target_position = Utils.Vector3_to_ground(target)
	var direction = origin_position.direction_to(target_position)

	if direction.length_squared() > 0.001:
		var target_yaw = Utils.get_yaw_from_direction(direction)
		_node.rotation.y = lerp_angle(_node.rotation.y, target_yaw, clamp(smooth_factor * get_physics_process_delta_time(), 0.0, 1.0))
		
		#var yaw_diff = Utils.angle_difference(owner.rotation.y, owner.previous_yaw)
		#owner.previous_yaw = owner.rotation.y
