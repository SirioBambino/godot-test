class_name StateMachine
extends Node

@export var initial_state : State

var states : Array[State] = []
var active_states : Array[State] = []


func _ready():
	for state_node in get_children():
		if state_node is State:
			states.append(state_node)
			
			if state_node.concurrent:
				add_state(state_node)
				state_node.enabled = true
			
			var has_transition := false
			for transition_node in state_node .get_children():
				if transition_node is Transition:
					has_transition = true
					state_node .transitions.append(transition_node)

					if transition_node is TransitionOnSignal:
						transition_node.triggered.connect(_on_transition_triggered.bind(transition_node))
				elif transition_node is StateMachine:
					state_node.child_state_machine = transition_node

			#assert(has_transition, "State '%s' must have at least one Transition." % child.name)

	#assert(states.size() >= 2, "State machine must have at least two States.")

	assert(initial_state != null, "State machine must have an 'initial_state' assigned.")
	assert(initial_state.get_parent() == self, "'initial_state' must be a child of this state machine.")
	
	add_state(initial_state)
	initial_state.enabled = true


func _process(delta : float):
	if active_states:
		for state in active_states:
			state.update(delta)
	
	
func _physics_process(delta):
	if active_states:
		for state in active_states:
			state.physics_update(delta)
			for transition in state.transitions:
				if transition is TransitionOnExpression and transition.can_transition():
					if add_state(transition.target_state):
						break
	#for state in states:
		#if state.concurrent:
			#state.physics_update(delta)
			#for transition in state.transitions:
				#if transition is TransitionOnExpression and transition.can_transition():
					#if add_state(transition.state):
						#break


#func change_state(new_state : State) -> bool:
	#if active_states:
		#if active_states == new_state: return false
		#active_states.exit()
		#active_states.enabled = false
	#
	#if new_state != null and new_state in states:
		#active_states = new_state
		#active_states.enter()
		#active_states.enabled = true
		#return true
	#
	#return false


func add_state(state : State) -> bool:
	if active_states:
		if state != null and state in states:
			active_states.append(state)
			state.enter()
			state.enabled = true
			return true
	
	return false


func _on_transition_triggered(transition: TransitionOnSignal) -> void:
	add_state(transition.target_state)
	
#func _ready():
	#for child in get_children():
		#if child is State:
			#states[child.name.to_lower()] = child
			#child.finished.connect(transition_to_next_state)
	#
	#if initial_state:
		#await get_tree().create_timer(0.1).timeout
		#initial_state.enter(null)
		#active_states = initial_state
		
#func _process(delta : float):
	#if current_state: current_state.update(delta)
	#
#func _physics_process(delta: float):
	#if current_state: current_state.physics_update(delta)
	
#func transition_to_next_state(state : State, new_state : State, data: Dictionary = {}) -> void:
	#if state != current_state: return
	#
	#new_state = states.get(new_state.name.to_lower())
	#if !new_state: return
	#
	#if current_state: current_state.exit()
	#
	#new_state.enter(null)
	#current_state = new_state
