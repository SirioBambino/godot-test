class_name Transition
extends RefCounted

##
## Represents a directed connection between two states in a state machine.
## 
## Transitions may include an optional guard expression to conditionally allow them.
## The transition does not perform the switch — it merely signals intent.
## 
## Responsibilities:
## - Hold source and target states.
## - Evaluate guards based on current context.
## - Validate structure and expressions.
##

## Source state (the state from which this transition originates).
var source: State

## Target state (the state to transition to).
var target: State

## Optional guard condition.
var guard: Callable

var use_history: bool = false

##
## Determines whether this transition should trigger.
##
## Evaluates the guard (if present) with the current event, machine, and context.
##
## @param event Dictionary containing the triggering event.
## @param state_machine The StateMachine executing the transition.
## @param context ExecutionContext with global or scene data.
## @return True if the transition should be taken.
func should_trigger(event: Dictionary, state_machine: StateMachine, context: ExecutionContext) -> bool:
	if not guard:
		return true

	if not guard.is_valid():
		push_warning("Guard callable is not valid.")
		return false

	var result: Variant = guard.call() #event, state_machine, context
	if typeof(result) == TYPE_BOOL:
		return result

	push_warning("Guard function did not return a bool. Defaulting to 'false'.")
	return false


##
## Validates the transition configuration.
##
## Checks for:
## - Source and target being assigned.
## - Guard expression (if any) being valid.
##
## @return Array of error messages as strings.
func validate() -> PackedStringArray:
	var errors: PackedStringArray = []
	
	if source == null:
		errors.append("Transition requires 'source' state to be set.")
	if target == null:
		errors.append("Transition requires 'target' state to be set.")

	if guard and not guard.is_valid():
		errors.append("Invalid guard '%s' on Transition '%s'" % [guard, self])

	return errors
