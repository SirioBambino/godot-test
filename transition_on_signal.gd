class_name TransitionOnSignal
extends Transition

@export var event_name: String = ""

func should_trigger(event: Dictionary, machine: StateMachine, context: ExecutionContext) -> bool:
	super.should_trigger(event, machine, context)
	return event.has("type") and event.type == "signal" and event.name == event_name
