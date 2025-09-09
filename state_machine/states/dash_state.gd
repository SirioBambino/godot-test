class_name DashState
extends State

@export var dash_duration := 0.5
var _timer := 0.0
var _is_dashing := false

func enter(data := {}):
	_timer = 0.0
	_is_dashing = true
	# start dash animation or logic here

func update(delta: float) -> void:
	if _is_dashing:
		_timer += delta
		# move the character forward or apply velocity here

		if _timer >= dash_duration:
			_is_dashing = false
			state_completed.emit()
