@abstract
class_name State
extends RefCounted

##
## Base class for all state types in the state machine.
##
## Each State defines lifecycle methods and transitions to other states.
## States are expected to be leaf nodes or compound parents (via subclassing).
##
## Responsibilities:
## - Handle enter/exit/update lifecycle.
## - Manage outgoing transitions.
## - Evaluate events to trigger transitions.
## - Validate its own configuration.
##

## Whether this state is currently enabled (managed by the state machine).
var enabled: bool = false

## List of outgoing transitions from this state.
var transitions: Array[Transition] = []

## Emitted when this state has completed its task.
signal state_completed

##
## Validates the state configuration.
## Calls `validate()` on all transitions.
## @return Array of error messages.
func validate() -> PackedStringArray:
	var errors: PackedStringArray = []
	for transition in transitions:
		errors.append_array(transition.validate())
	return errors


##
## Optional initializer for data required by the state.
##
## Can be used to inject configuration or precomputed resources.
##
## @param data Optional dictionary of initialization data.
func init(_data := {}) -> void:
	pass


##
## Called when the state is entered.
##
## The state should prepare any internal logic or side-effects here.
##
## @param context ExecutionContext for accessing game/application data.
func enter(_context: ExecutionContext) -> void:
	pass


##
## Called when the state is exited.
##
## Should clean up any side-effects or reset internal variables.
##
## @param context ExecutionContext for accessing game/application data.
func exit(_context: ExecutionContext) -> void:
	pass


##
## Called every frame via StateMachine.step.
##
## @param delta Time since last frame.
## @param context ExecutionContext for accessing game/application data.
func update(_delta: float, _context: ExecutionContext) -> void:
	pass


##
## Optional hook for physics-based updates (if needed).
##
## @param delta Physics time step.
## @param context ExecutionContext for accessing game/application data.
func physics_update(_delta: float, _context: ExecutionContext) -> void:
	pass


##
## Processes an incoming event and evaluates outgoing transitions.
##
## If a transition is triggered, it requests it from the state machine.
##
## @param event Dictionary describing the event.
## @param machine The StateMachine that owns this state.
## @param context ExecutionContext for accessing shared data.
func handle_event(event: Dictionary, machine: StateMachine, context: ExecutionContext) -> void:
	for transition in transitions:
		if transition.should_trigger(event, machine, context):
			machine.request_transition(transition)
			return
