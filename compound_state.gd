class_name CompoundState
extends State

##
## A compound (hierarchical) state containing multiple regions.
##
## Each region owns an embedded StateMachine that runs in parallel.
##
## Responsibilities:
## - Manage and delegate lifecycle to child regions.
## - Forward updates and events to all regions.
## - Evaluate its own outgoing transitions when active.
##

## List of concurrent regions in this compound state.
var regions: Array[Region] = []


##
## Called when this compound state is entered.
##
## Starts all nested region state machines.
##
## @param context ExecutionContext passed to regions.
func enter(context: ExecutionContext) -> void:
	for region in regions:
		region.start(context)


##
## Called when this compound state is exited.
##
## Stops all nested region state machines.
##
## @param context ExecutionContext passed to regions.
func exit(context: ExecutionContext) -> void:
	for region in regions:
		region.stop(context)


##
## Called every frame to update this compound state.
##
## Forwards update to all contained regions.
##
## @param delta Time since last update.
## @param context ExecutionContext passed to updates.
func update(delta: float, context: ExecutionContext) -> void:
	for region in regions:
		region.step(delta, context)


##
## Called every physics frame to update this compound state.
##
## Forwards physics updates to all contained regions.
##
## @param delta Physics timestep.
## @param context ExecutionContext passed to updates.
func physics_update(delta: float, context: ExecutionContext) -> void:
	for region in regions:
		region.physics_step(delta, context)


##
## Handles an external event.
##
## First forwards to regions, then evaluates own outgoing transitions.
##
## @param event Dictionary describing the event.
## @param state_machine The owning root StateMachine.
## @param context ExecutionContext passed to handlers.
func handle_event(event: Dictionary, state_machine: StateMachine, context: ExecutionContext) -> void:
	for region in regions:
		region.state_machine.process_event(event, context)
	
	for transition in transitions:
		if transition.should_trigger(event, state_machine, context):
			state_machine.request_transition(transition)
			return


##
## Validates the compound state and its regions.
##
## Ensures:
## - At least one region exists.
## - Each region contains a valid StateMachine.
##
## @return Array of error messages (empty if valid).
func validate() -> PackedStringArray:
	var errors: PackedStringArray = []

	if regions.is_empty():
		errors.append("CompoundState '%s' has no regions defined." % self)

	for region in regions:
		errors.append_array(region.validate())

	errors.append_array(super.validate())

	return errors
