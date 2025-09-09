class_name TransitionOnInput
extends Transition

enum InputCondition {
	JUST_PRESSED,
	JUST_RELEASED,
	IS_PRESSED,
	PRESSED_FOR_TIME
}

@export var action: String
@export var condition: InputCondition = InputCondition.JUST_PRESSED
@export var required_hold_time: float = 1.0 # Only used for PRESSED_FOR_TIME

var _hold_timer := 0.0
var _was_pressed_last_frame := false

func _ready():
	#super._ready()
	assert(action != null and action != "", "TransitionOnInput's action must be set.")
	assert(InputMap.has_action(action), "TransitionOnInput's action doesn't exist.")

func can_transition() -> bool:
	match condition:
		InputCondition.JUST_PRESSED:
			return Input.is_action_just_pressed(action)
		
		InputCondition.JUST_RELEASED:
			return Input.is_action_just_released(action)
		
		InputCondition.IS_PRESSED:
			return Input.is_action_pressed(action)
		
		InputCondition.PRESSED_FOR_TIME:
			# Track how long the button is held
			if Input.is_action_pressed(action):
				_hold_timer += get_process_delta_time()
				if _hold_timer >= required_hold_time:
					return true
			else:
				_hold_timer = 0.0
			return false

	return false
