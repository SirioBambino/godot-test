class_name TransitionOnTimer
extends Transition

@export var duration: float = 1.0
var elapsed: float = 0.0
var running: bool = false

func start_timer():
	elapsed = 0.0
	running = true

func stop_timer():
	running = false

func tick(delta: float, machine: StateMachine, context) -> void:
	if not running: return
	elapsed += delta
	if elapsed >= duration:
		machine.request_transition(self)
		stop_timer()

func should_trigger(event: Dictionary, machine: StateMachine, context) -> bool:
	# Timer transitions don’t care about external events
	return false
