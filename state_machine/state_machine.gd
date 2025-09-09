class_name StateMachine
extends Node

@export var parent : NodePath
@export var initial_states : Array[State] = []

@export var states : Array[State] = []
@export var active_states : Array[State] = []

var _parent : Node

func _ready():
	_parent = get_node(parent)
	assert(_parent != null, "State machine %s must have a parent assigned."  % self.name)	
	assert(initial_states.size() > 0, "State machine %s must have at least one initial state assigned." % self.name)
	
	if get_parent() is HierarchicalState:
		process_mode = Node.PROCESS_MODE_DISABLED
	else:
		process_mode = Node.PROCESS_MODE_INHERIT
	
	for state_node in get_children():
		if state_node is State:
			states.append(state_node)
			state_node.state_machine = self
			state_node.init()
			
			if state_node.concurrent:
				assert(!state_node.priority, "States can't be both priority and concurrent.")
			
			var has_transition := false
			for transition_node in state_node .get_children():
				if transition_node is Transition:
					has_transition = true
					state_node .transitions.append(transition_node)

					if transition_node is TransitionOnSignal or transition_node is TransitionOnTimer:
						transition_node.triggered.connect(_on_transition_triggered.bind(transition_node))
				elif transition_node is StateMachine:
					state_node.child_state_machine = transition_node
	
	for state in initial_states:
		assert(state.get_parent() == self, "Initial state %s must be a child of the state machine %s." % [state.name, self.name])
		#assert(!state.concurrent, "The State Machine %s's initial state %s can't be concurrent.")
		active_states.append(state)
		state.enabled = true
		state.enter()

func _process(delta : float):
	if active_states:
		for state in active_states:
			state.update(delta)
	
	
func _physics_process(delta):
	for state in states:
		if state.concurrent and active_states.find(state) == -1:
			for transition in state.transitions:
				if (transition is TransitionOnExpression or transition is TransitionOnInput) and transition.can_transition():
					if change_state(transition.current_state, transition.target_state):
						break
		#if state.prioriy:
			# I think logic should be here
	if active_states:
		for state in active_states:
			var name = state.name
			state.physics_update(delta)
			for transition in state.transitions:
				if (transition is TransitionOnExpression or transition is TransitionOnInput) and transition.can_transition():
					if change_state(transition.current_state, transition.target_state):
						break


func change_state(current_state: State, target_state : State) -> bool:
	if active_states and current_state != null:
		if target_state == null:
			current_state.enabled = !current_state.enabled
			if current_state.enabled:
				current_state.enter()
				active_states.append(current_state)
			else:
				var current_state_index = active_states.find(current_state)
				if current_state_index == -1: return false
				current_state.exit()
				current_state.enabled = false
				active_states.remove_at(current_state_index)
		else:
			var current_state_index = active_states.find(current_state)
			if current_state_index == -1: return false
			current_state.exit()
			current_state.enabled = false
			active_states.remove_at(current_state_index)
	else:
		return false
	
	if target_state != null and target_state in states:
		active_states.append(target_state)
		target_state.enter()
		target_state.enabled = true
		
		for transition in target_state.transitions:
			if transition is TransitionOnTimer:
				transition._timer.start()
		return true
	
	return false


func _on_transition_triggered(transition: TransitionOnSignal) -> void:
	change_state(transition.current_state, transition.target_state)
