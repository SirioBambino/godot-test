class_name State
extends Node

var enabled : bool = false
@export var transitions : Array[Transition] = []

@export var concurrent : bool = false

func enter(data := {}) -> void:
	pass
	
func exit() -> void:
	pass

## Called by the state machine on the process loop.
func update(_delta : float) -> void:
	pass

## Called by the state machine on the physics process loop.
func physics_update(_delta : float) -> void:
	pass 
	
#func check_transitions(entity: Node) -> Node:
	#for transition in transitions:
		#if transition.should_transition(entity):
			#return get_node(transition.target_state)
	#return null
