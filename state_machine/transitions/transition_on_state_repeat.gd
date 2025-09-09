class_name TransitionOnStateRepeat
extends Transition

@export var required_count: int = 3
var _count: int = 0
signal triggered

func _ready():
	super._ready()
	current_state.action_completed.connect(_on_action_completed)

func _on_action_completed():
	_count += 1

func can_transition() -> bool:
	if _count >= required_count:
		triggered.emit()
	return true
