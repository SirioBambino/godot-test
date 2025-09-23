class_name StateMachine
extends RefCounted
##
## A statechart implementation.
##
## This class manages the lifecycle of states and transitions, including entering and exiting states,
## processing events, updating active states, and handling transition requests.
## [br][br]
## [b]Responsibilities:[/b][br]
## - Track current active states.[br]
## - Manage pending transitions and apply them with proper hierarchical exit/entry ordering.[br]
## - Emit signals when states are entered/exited and transitions are applied.[br]
## [br][br]
## Initialisation requires a list of top-level states and an initial state.
## [br][br]
## [b]Usage:[/b][br]
## 1. Construct with states and initial state.[br]
## 2. Call `start()` with a context to begin execution.[br]
## 3. Periodically call `step(delta, context)` to update states.[br]
## 4. Send events using `process_event(event, context)` to trigger transitions.[br]
## 5. Call `stop()` to terminate and exit all active states.[br]
##

##
## Emitted when a state is entered.
## @param state The State instance that was just entered.
##
signal state_entered(state: State)

##
## Emitted when a state is exited.
## @param state The State instance that was just exited.
##
signal state_exited(state: State)

##
## Emitted after a transition has been applied.
## @param transition The Transition instance that was triggered.
##
signal transition_applied(transition: Transition)

##
## List of all top-level states belonging to this state machine.
## Nested states inside compound states are managed recursively.
var states: Array[State] = []

##
## The first state the machine enters when started.
var initial_state: State = null

##
## List of currently active leaf states.
## These represent the current configuration of the running state machine.
var active_states: Array[State] = []

##
## Queue of pending transitions requested to be applied.
var pending_transitions: Array[Transition] = []

##
## True if the state machine has been started and is currently running.
var running: bool = false

##
## Tracks the total elapsed time since the state machine was started.
var time: float = 0.0

##
## Constructs a new StateMachine with the given states and initial state.
#
## @param _states Array of top-level State instances managed by this machine.
## @param _initial_state The initial State to enter when the machine starts.
#
## Validates the setup and logs errors via `push_error` if invalid.
func _init(_states: Array[State], _initial_state: State) -> void:
	states = _states.duplicate()
	initial_state = _initial_state
	
	#var errors: PackedStringArray = validate()
	#if errors:
		#for error in errors:
			#push_error(error)


##
## Validates the state machine configuration.
##
## Checks for:
## - Presence of an initial state.
## - Initial state belonging to the states list.
## - Validation of all contained states recursively.
##
## @return Array of error messages as strings. Empty if no errors found.
func validate() -> PackedStringArray:
	var errors: PackedStringArray = []
	if initial_state == null:
		errors.append("'StateMachine' requires the 'initial_state' property to be set.")
	else:
		if not states.has(initial_state):
			errors.append("Initial state '%s' is not a valid state of 'StateMachine'." % initial_state)
		for state in states:
			errors.append_array(state.validate())
	return errors


##
## Starts the state machine execution.
##
## Enters the initial state and resets internal timing.
##
## @param context ExecutionContext passed to state enter methods.
func start(context: ExecutionContext, entry_state: State = null) -> void:
	if running:
		return
	
	active_states.clear()
	
	if entry_state == null:
		_enter_state(initial_state, context)
	else:
		_enter_state(entry_state, context)
	
	running = true
	time = 0.0


##
## Stops the state machine execution.
##
## Exits all currently active states and clears the active state list.
##
## @param context ExecutionContext passed to state exit methods.
func stop(context: ExecutionContext) -> void:
	if not running:
		return
	
	for state: State in states:
		_stop_state_recursive(state, context)
	
	active_states.clear()
	running = false


func _stop_state_recursive(state: State, context: ExecutionContext) -> void:
	if state is CompoundState and state.enabled:
		# Stop all nested regions first
		for region: Region in state.regions:
			if region.state_machine.running:
				region.state_machine.stop(context)
	
	if state.enabled:
		_exit_state(state, context)


## Advances the state machine by a time delta.
##
## Updates all active states and applies any pending transitions.
##
## @param delta Time elapsed since last call.
## @param context ExecutionContext passed to update methods.
func step(delta: float, context: ExecutionContext) -> void:
	if not running:
		return
	time += delta
	
	var applied: bool = false
	while pending_transitions.size() > 0:
		var transition: Transition = pending_transitions.pop_front()
		apply_transition(transition, context)
		applied = true
	
	if not applied:
		for state in active_states:
			state.update(delta, context)
		
		_step_compound_states(states, delta, context)


func _step_compound_states(candidates: Array[State], delta: float, context: ExecutionContext) -> void:
	for state in candidates:
		if state is CompoundState and state.enabled:
			for region: Region in state.regions:
				if region.state_machine.running:
					region.state_machine.step(delta, context)
				_step_compound_states(region.state_machine.states, delta, context)


##
## Advances the state machine by a physics timestep.
##
## It updates all active states, but does not process transitions.
##
## @param delta Time elapsed since last physics frame.
## @param context ExecutionContext passed to update methods.
func physics_step(delta: float, context: ExecutionContext) -> void:
	if not running:
		return
	
	for state in active_states:
		state.physics_update(delta, context)
	
	_physics_step_compound_states(states, delta, context)


func _physics_step_compound_states(candidates: Array[State], delta: float, context: ExecutionContext) -> void:
	for state in candidates:
		if state is CompoundState and state.enabled:
			for region: Region in state.regions:
				if region.state_machine.running:
					region.state_machine.physics_step(delta, context)
				_physics_step_compound_states(region.state_machine.states, delta, context)


##
## Processes an external event.
##
## Sends the event to all active states for handling.
##
## @param event Arbitrary dictionary describing the event.
## @param context ExecutionContext passed to event handlers.
func process_event(event: Dictionary, context: ExecutionContext) -> void:
	for state in active_states:
		state.handle_event(event, self, context)
	
	_process_event_compound_states(states, event, context)


func _process_event_compound_states(candidates: Array[State], event: Dictionary, context: ExecutionContext) -> void:
	for state in candidates:
		if state is CompoundState and state.enabled:
			for region: Region in state.regions:
				if region.state_machine.running:
					region.state_machine.process_event(event, context)
		if state is CompoundState:
			for region: Region in state.regions:
				_process_event_compound_states(region.state_machine.states, event, context)


##
## Requests a transition to be applied.
##
## Adds the transition to the pending transitions queue if not already present.
##
## @param transition The Transition instance to request.
func request_transition(transition: Transition) -> void:
	if not pending_transitions.has(transition):
		pending_transitions.append(transition)


##
## Applies a transition, performing hierarchical state exit and entry.
##
## 1. Calculates the lowest common ancestor (LCA) between source and target states.
## 2. Exits states from source leaf up to but not including the LCA.
## 3. Enters states from the LCA down to the target leaf.
## 4. Emits the `transition_applied` signal.
##
## @param transition The Transition instance to apply.
## @param context ExecutionContext passed to enter/exit methods.
func apply_transition(transition: Transition, context: ExecutionContext) -> void:
	if transition == null:
		return
		
	var source_path: Array = get_path_to_state(transition.source)
	var target_path: Array = get_path_to_state(transition.target)
	if source_path.is_empty() or target_path.is_empty():
		push_error("Transition source or target state not found in StateMachine hierarchy.")
		return
	
	var lca: State = _find_lowest_common_ancestor(source_path, target_path)
	var exit_index: int = -1
	if lca != null:
		exit_index = source_path.find(lca)
	
	for i in range(source_path.size() - 1, exit_index, -1):
		_exit_state(source_path[i], context)
	
	emit_signal("transition_applied", transition)
	
	var enter_index: int = 0
	if lca != null:
		enter_index = target_path.find(lca) + 1
	
	for i in range(enter_index, target_path.size()):
		_enter_state(target_path[i], context)


##
## Internal helper to enter a state and its nested regions (if compound).
##
## Executes state's enter method, adds state to the active_states list and emits `state_entered`.
##
## @param state The State instance to enter.
## @param context ExecutionContext passed to enter methods.
func _enter_state(state: State, context: ExecutionContext) -> void:
	state.enabled = true
	state.enter(context)
	
	if not (state is CompoundState):
		active_states.append(state)
	
	emit_signal("state_entered", state)


##
## Internal helper to exit a state and its nested regions (if compound).
##
## Executes state's exit method, removes state from the active_states list and emits `state_exited`.
##
## @param state The State instance to exit.
## @param context ExecutionContext passed to exit methods.
func _exit_state(state: State, context: ExecutionContext) -> void:
	state.exit(context)
	state.enabled = false
	
	if not (state is CompoundState):
		active_states.erase(state)
	
	emit_signal("state_exited", state)


##
## Finds the lowest common ancestor (LCA) between two state paths.
##
## @param path_a Array of State instances from root to source.
## @param path_b Array of State instances from root to target.
## @return The State instance representing the LCA, or null if none found.
func _find_lowest_common_ancestor(path_a: Array, path_b: Array) -> State:
	var mininum_length: int = min(path_a.size(), path_b.size())
	var lowest_common_ancestor: State = null
	for i in range(mininum_length):
		if path_a[i] == path_b[i]:
			lowest_common_ancestor = path_a[i]
		else:
			break
	return lowest_common_ancestor


##
## Returns the path from the root states down to the specified target state.
##
## Searches recursively through the state hierarchy.
##
## @param target The State instance to find.
## @return Array of State instances from root down to the target. Empty if not found.
func get_path_to_state(target: State) -> Array[State]:
	return _find_path_recursive(target, states)


##
## Recursively searches candidate states for the target state.
##
## @param target The State instance to find.
## @param candidates Array of State instances to search in.
## @return Array of State instances representing the path from the current candidate to target.
func _find_path_recursive(target: State, candidates: Array[State]) -> Array[State]:
	var path: Array[State] = []
	for state in candidates:
		if state == target:
			path.append(state)
			break
		
		if state is CompoundState:
			for region: Region in state.regions:
				var sub_path: Array[State] = _find_path_recursive(target, region.state_machine.states)
				if not sub_path.is_empty():
					path.append(state)
					path += sub_path
					break
	return path
