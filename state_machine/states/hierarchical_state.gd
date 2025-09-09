class_name HierarchicalState
extends State

var child_state_machine : StateMachine

func _ready() -> void:
	child_state_machine = get_child(0)
	assert(child_state_machine is StateMachine, "HierarchicalState's child node must be a StateMachine node")
	#assert(get_child_count() == 1, "HierarchicalState node must have 1 child node.")
	if enabled:
		child_state_machine.process_mode = Node.PROCESS_MODE_INHERIT


func enter(data := {}) -> void:
	print("xx")
	child_state_machine.process_mode = Node.PROCESS_MODE_INHERIT


func exit() -> void:
	child_state_machine.process_mode = Node.PROCESS_MODE_DISABLED
