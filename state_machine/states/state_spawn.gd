class_name StateSpawn
extends PlayerState

var position : Vector3


#func enter(data := {}) -> void:
	#if "spawn_location" in data:
		#position = data["spawn_location"]
	#else:
		#position = Vector3.ZERO


func exit() -> void:
	pass


func update(_delta : float) -> void:
	pass


func physics_update(_delta : float) -> void:
	pass
	#if player.animation_player.current_animation != "player_animations/idle":
		#player.animation_player.play("player_animations/idle") 
