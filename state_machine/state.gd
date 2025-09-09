class_name State
extends Node


var state_machine : StateMachine
var enabled : bool = false
var transitions : Array[Transition] = []

@export var concurrent : bool = false
@export var priority : bool = false

signal state_completed

func init(data := {}) -> void:
	pass


func enter() -> void:
	pass


func exit() -> void:
	pass


func update(_delta : float) -> void:
	pass


func physics_update(_delta : float) -> void:
	pass 
	
#func check_transitions(entity: Node) -> Node:
	#for transition in transitions:
		#if transition.should_transition(entity):
			#return get_node(transition.target_state)
	#return null
