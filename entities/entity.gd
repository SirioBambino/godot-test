class_name Entity
extends CharacterBody3D

var collision_shape : CollisionShape3D
var animation_player : AnimationPlayer
var animation_tree : AnimationTree
var state_machine : StateMachine

@export var stats : EntityStats

func _ready() -> void:
	collision_shape = get_node("CollisionShape3D")
	animation_player = get_node("AnimationPlayer")
	animation_tree = get_node("AnimationTree")
	state_machine = get_node("StateMachine")
	
	animation_player.playback_default_blend_time = 0.2
