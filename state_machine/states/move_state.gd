class_name MoveState
extends State

var _node : Entity

const DIR_THRESHOLD := 0.2

var input_dir_blend = Vector2.ZERO

func init(data := {}) -> void:
	if state_machine:
		_node = state_machine._parent
	assert(_node is Entity, "Move state %s can only be used on an Entity node." % _node.name)

func enter(data := {}) -> void:
	pass


func exit() -> void:
	pass


func update(_delta : float) -> void:
	pass


func physics_update(_delta : float) -> void:
	var stats = _node.get_stats()
	var forward = -_node.basis.z
	var right = _node.basis.x

	if _node.get_stats().movement_direction:
		var forward_amount = stats.movement_direction.dot(forward)
		var right_amount = stats.movement_direction.dot(right)
	
		var speed_multiplier = stats.SPEED_SIDE
	
		if forward_amount > DIR_THRESHOLD:
			speed_multiplier = stats.SPEED_BACKWARD
		elif forward_amount < -DIR_THRESHOLD:
			speed_multiplier = stats.SPEED_FORWARD
	
		if stats.movement_direction:
			_node.velocity.x = stats.movement_direction.x * stats.speed * speed_multiplier
			_node.velocity.z = stats.movement_direction.z * stats.speed * speed_multiplier
		else:
			_node.velocity.x = move_toward(_node.velocity.x, 0, stats.speed * speed_multiplier)
			_node.velocity.z = move_toward(_node.velocity.z, 0, stats.speed * speed_multiplier)
		
		_node.move_and_slide()
		
		var blend_vector = Vector2(right_amount, -forward_amount)
		
		
		
	#print(blend_vector)

	#input_dir_blend = input_dir_blend.move_toward(blend_vector * 1.1, _delta * 10)
	#player.animation_tree.set("parameters/Movement/blend_position", input_dir_blend)
	
	#player.animation_tree.set("parameters/Movement/blend_position", Vector2(player.movement_direction.x, player.movement_direction.z))
	#var animation := ""
#
	#if abs(forward_amount) >= abs(right_amount):
		#print("Forward: " + str(forward_amount))
		## More forward/back than sideways
		#if forward_amount > DIR_THRESHOLD:
			#animation = "player_animations/walk_backward"
		#elif forward_amount < -DIR_THRESHOLD:
			#animation = "player_animations/walk"
	#else:
		#print("Right: " + str(right_amount))
		## More sideways than forward/back
		#if right_amount > DIR_THRESHOLD:
			#animation = "player_animations/walk_right"
		#elif right_amount < -DIR_THRESHOLD:
			#animation = "player_animations/walk_left"
#
	#if animation != "" and player.animation_player.current_animation != animation:
		#player.animation_player.play(animation)
