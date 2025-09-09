class_name Transition
extends Node

@export var target_state : State
@export var current_state : State

#func _ready():
	#print(get_parent())
	#current_state = get_parent()
	
	#assert(current_state is State, "Transition node must be a child of a State node.")


# triggered
func can_transition() -> bool:
	return false
