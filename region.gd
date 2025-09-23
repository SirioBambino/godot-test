class_name Region
extends RefCounted

## The StateMachine that runs within this region.
var state_machine: StateMachine

var last_active_state: State

## Returns true if the region has an active state running.
func is_active() -> bool:
	return state_machine != null and state_machine.running


## Returns the currently active states in this region.
func get_active_states() -> Array[State]:
	if state_machine == null:
		return []
	return state_machine.active_states.duplicate()


## Starts the region (helper to start the internal machine).
func start(context: ExecutionContext, use_history: bool = false) -> void:
	if state_machine != null and not state_machine.running:
		if use_history and last_active_state != null:
			state_machine.start(context, last_active_state)
		else:
			state_machine.start(context)


## Stops the region (helper to stop the internal machine).
func stop(context: ExecutionContext) -> void:
	if state_machine != null and state_machine.running:
		state_machine.stop(context)


## Steps the region by delta.
func step(delta: float, context: ExecutionContext) -> void:
	if state_machine != null and state_machine.running:
		state_machine.step(delta, context)


## Optional: For physics_step if needed
func physics_step(delta: float, context: ExecutionContext) -> void:
	if state_machine != null and state_machine.running:
		state_machine.physics_step(delta, context)


## Validates the region and its state machine.
func validate() -> PackedStringArray:
	var errors: PackedStringArray = []
	if state_machine == null:
		return ["Region '%s' has no state machine assigned." % self]
	errors.append_array(state_machine.validate())
	return errors
