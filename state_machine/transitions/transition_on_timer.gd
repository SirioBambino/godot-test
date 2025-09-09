class_name TransitionOnTimer
extends Transition

@export var wait_time: float = 1.0
@export var one_shot: bool = true

var _timer: Timer

signal triggered

func _ready():
	#super._ready()
	_timer = Timer.new()
	_timer.wait_time = wait_time
	_timer.one_shot = one_shot
	add_child(_timer)
	_timer.timeout.connect(can_transition)

func can_transition() -> bool:
	triggered.emit()
	return true
