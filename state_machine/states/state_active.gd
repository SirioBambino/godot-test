class_name StateActive
extends PlayerState

const DIR_THRESHOLD := 0.2

var input_dir_blend = Vector2.ZERO

func enter(data := {}) -> void:
	pass
	
func exit() -> void:
	pass

func update(_delta : float) -> void:
	pass

func physics_update(_delta : float) -> void:
	var forward = -player.basis.z
	var right = player.basis.x

	var forward_amount = player.movement_direction.dot(forward)
	var right_amount = player.movement_direction.dot(right)
	
	var speed_multiplier = player.stats.SPEED_SIDE
	
	if forward_amount > DIR_THRESHOLD:
		speed_multiplier = player.stats.SPEED_BACKWARD
	elif forward_amount < -DIR_THRESHOLD:
		speed_multiplier = player.stats.SPEED_FORWARD
	
	if player.movement_direction:
		player.velocity.x = player.movement_direction.x * player.stats.speed * speed_multiplier
		player.velocity.z = player.movement_direction.z * player.stats.speed * speed_multiplier
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.stats.speed * speed_multiplier)
		player.velocity.z = move_toward(player.velocity.z, 0, player.stats.speed * speed_multiplier)
	
	player.move_and_slide()
	
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
